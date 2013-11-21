# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
WANT_AUTOCONF="2.1"
MOZ_ESR="1"

MY_PN="firefox"
MOZ_PV="${MY_PN}-${PV}"
TOR_PV="2.3.25-15"

if [[ ${MOZ_ESR} == 1 ]]; then
	# ESR releases have slightly version numbers
	MOZ_PV="${PV}esr"
fi

# Patch version
PATCH="${MY_PN}-17.0-patches-0.6"
# Upstream ftp release URI that's used by mozlinguas.eclass
# We don't use the http mirror because it deletes old tarballs.
MOZ_FTP_URI="ftp://ftp.mozilla.org/pub/${MY_PN}/releases/"
MOZ_HTTP_URI="http://ftp.mozilla.org/pub/${MY_PN}/releases/"

inherit check-reqs flag-o-matic toolchain-funcs eutils gnome2-utils mozconfig-3 multilib pax-utils fdo-mime autotools virtualx

DESCRIPTION="Torbrowser without vidalia or tor"
HOMEPAGE="https://www.torproject.org/projects/torbrowser.html.en"

# may work on other arches, but untested
KEYWORDS="~amd64 ~x86"
SLOT="0"
# BSD license applies to torproject-related code like the patches
# icons are under CCPL-Attribution-3.0
LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )
	BSD
	CC-BY-3.0"
IUSE="gstreamer +jit selinux system-sqlite"

# More URIs appended below...
SRC_URI="${SRC_URI}
	http://dev.gentoo.org/~anarchy/mozilla/patchsets/${PATCH}.tar.xz
	http://dev.gentoo.org/~nirbheek/mozilla/patchsets/${PATCH}.tar.xz
	amd64? ( https://www.torproject.org/dist/${PN}/linux/tor-browser-gnu-linux-x86_64-${TOR_PV}-dev-en-US.tar.gz )
	x86? ( https://www.torproject.org/dist/${PN}/linux/tor-browser-gnu-linux-i686-${TOR_PV}-dev-en-US.tar.gz )"

ASM_DEPEND=">=dev-lang/yasm-1.1"

# Mesa 7.10 needed for WebGL + bugfixes
RDEPEND="
	>=sys-devel/binutils-2.16.1
	>=dev-libs/nss-3.14.1
	>=dev-libs/nspr-4.9.4
	>=dev-libs/glib-2.26:2
	>=media-libs/mesa-7.10
	>=media-libs/libpng-1.5.11[apng]
	virtual/libffi
	gstreamer? ( media-plugins/gst-plugins-meta:0.10[ffmpeg] )
	system-sqlite? ( || (
		>=dev-db/sqlite-3.7.16:3[secure-delete,debug=]
		=dev-db/sqlite-3.7.15*[fts3,secure-delete,threadsafe,unlock-notify,debug=]
		=dev-db/sqlite-3.7.14*[fts3,secure-delete,threadsafe,unlock-notify,debug=]
		=dev-db/sqlite-3.7.13*[fts3,secure-delete,threadsafe,unlock-notify,debug=]
	) )
	>=media-libs/libvpx-1.0.0
	kernel_linux? ( media-libs/alsa-lib )
	selinux? ( sec-policy/selinux-mozilla )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	amd64? ( ${ASM_DEPEND}
		virtual/opengl )
	x86? ( ${ASM_DEPEND}
		virtual/opengl )
	!www-misc/torbrowser-profile"

SRC_URI="${SRC_URI}
	${MOZ_FTP_URI}/${MOZ_PV}/source/firefox-${MOZ_PV}.source.tar.bz2"
if [[ ${MOZ_ESR} == 1 ]]; then
	S="${WORKDIR}/mozilla-esr${PV%%.*}"
else
	S="${WORKDIR}/mozilla-release"
fi

QA_PRESTRIPPED="usr/$(get_libdir)/${PN}/${MY_PN}/firefox"

# see mozcoreconf-2.eclass
mozversion_is_new_enough() {
	if [[ $(get_version_component_range 1) -ge 17 ]] ; then
		return 0
	fi
	return 1
}

pkg_setup() {
	moz_pkgsetup

	# Avoid PGO profiling problems due to enviroment leakage
	# These should *always* be cleaned up anyway
	unset DBUS_SESSION_BUS_ADDRESS \
		DISPLAY \
		ORBIT_SOCKETDIR \
		SESSION_MANAGER \
		XDG_SESSION_COOKIE \
		XAUTHORITY

	# Ensure we have enough disk space to compile
	if use debug || use test ; then
		CHECKREQS_DISK_BUILD="8G"
	else
		CHECKREQS_DISK_BUILD="4G"
	fi
	check-reqs_pkg_setup
}

src_unpack() {
	default
	unzip -q -d "${WORKDIR}"/omni "${WORKDIR}"/tor-browser_en-US/App/Firefox/omni.ja || die
}

src_prepare() {
	# Apply our patches
	EPATCH_SUFFIX="patch" \
	EPATCH_FORCE="yes" \
	epatch "${WORKDIR}/firefox"

	# Torbrowser patches for firefox, check regularly/for every version-bump
	# https://gitweb.torproject.org/torbrowser.git/tree/HEAD:/src/current-patches/firefox
	EPATCH_EXCLUDE="0011-Rebrand-Firefox-to-TorBrowser.patch" \
	EPATCH_SUFFIX="patch" \
	EPATCH_FORCE="yes" \
	epatch "${FILESDIR}/${PN}-patches"

	# patch fails to apply git binary patches
	epatch "${FILESDIR}/0011-Rebrand-Firefox-to-TorBrowser-no-binary.patch"

	# see https://gitweb.torproject.org/torbrowser.git/blob/HEAD:/build-scripts/linux.mk#l85
	cp "${FILESDIR}"/branding/* "${S}"/browser/branding/official || die

	# Allow user to apply any additional patches without modifing ebuild
	epatch_user

	# Enable gnomebreakpad
	if use debug ; then
		sed -i -e "s:GNOME_DISABLE_CRASH_DIALOG=1:GNOME_DISABLE_CRASH_DIALOG=0:g" \
			"${S}"/build/unix/run-mozilla.sh || die "sed failed!"
	fi

	# Disable gnomevfs extension
	sed -i -e "s:gnomevfs::" "${S}/"browser/confvars.sh \
		-e "s:gnomevfs::" "${S}/"xulrunner/confvars.sh \
		|| die "Failed to remove gnomevfs extension"

	# Ensure that plugins dir is enabled as default and is different from firefox-location
	sed -i -e "s:/usr/lib/mozilla/plugins:/usr/$(get_libdir)/${PN}/${MY_PN}/plugins:" \
		"${S}"/xpcom/io/nsAppFileLocationProvider.cpp || die "sed failed to replace plugin path!"

	# Fix sandbox violations during make clean, bug 372817
	sed -e "s:\(/no-such-file\):${T}\1:g" \
		-i "${S}"/config/rules.mk \
		-i "${S}"/js/src/config/rules.mk \
		-i "${S}"/nsprpub/configure{.in,} \
		|| die

	#Fix compilation with curl-7.21.7 bug 376027
	sed -e '/#include <curl\/types.h>/d'  \
		-i "${S}"/toolkit/crashreporter/google-breakpad/src/common/linux/http_upload.cc \
		-i "${S}"/toolkit/crashreporter/google-breakpad/src/common/linux/libcurl_wrapper.cc \
		-i "${S}"/config/system-headers \
		-i "${S}"/js/src/config/system-headers || die "Sed failed"

	# Don't exit with error when some libs are missing which we have in
	# system.
	sed '/^MOZ_PKG_FATAL_WARNINGS/s@= 1@= 0@' \
		-i "${S}"/browser/installer/Makefile.in || die

	# Don't error out when there's no files to be removed:
	sed 's@\(xargs rm\)$@\1 -f@' \
		-i "${S}"/toolkit/mozapps/installer/packager.mk || die

	eautoreconf
}

src_configure() {
	MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}/${MY_PN}"
	MEXTENSIONS="default"

	####################################
	#
	# mozconfig, CFLAGS and CXXFLAGS setup
	#
	####################################

	# see mozconfig-3.eclass
	cp browser/config/mozconfig .mozconfig \
		|| die "cp browser/config/mozconfig failed"

	mozconfig_init
	mozconfig_config

	# We must force enable jemalloc 3 threw .mozconfig
	echo "export MOZ_JEMALLOC=1" >> ${S}/.mozconfig

	mozconfig_annotate '' --prefix="${EPREFIX}"/usr
	mozconfig_annotate '' --libdir="${EPREFIX}"/usr/$(get_libdir)/${PN}
	mozconfig_annotate '' --enable-extensions="${MEXTENSIONS}"
	mozconfig_annotate '' --disable-gconf
	mozconfig_annotate '' --disable-mailnews
	mozconfig_annotate '' --with-system-png
	mozconfig_annotate '' --enable-system-ffi

	# Other ff-specific settings
	mozconfig_annotate '' --with-default-mozilla-five-home=${MOZILLA_FIVE_HOME}
	mozconfig_annotate '' --target="${CTARGET:-${CHOST}}"
	mozconfig_annotate '' --build="${CTARGET:-${CHOST}}"

	mozconfig_use_enable gstreamer
	mozconfig_use_enable system-sqlite
	# Both methodjit and tracejit conflict with PaX
	mozconfig_use_enable jit methodjit
	mozconfig_use_enable jit tracejit

	# TorBrowser
	# see https://gitweb.torproject.org/torbrowser.git/blob/HEAD:/build-scripts/config/mozconfig-lin-x86_64
	mozconfig_annotate 'torbrowser' --enable-official-branding
	mozconfig_annotate 'torbrowser' --disable-tests
	mozconfig_annotate 'torbrowser' --disable-debug
	mozconfig_annotate 'torbrowser' --disable-maintenance-service
	mozconfig_annotate 'torbrowser' --disable-crashreporter
	mozconfig_annotate 'torbrowser' --disable-webrtc
	mozconfig_annotate 'torbrowser' --with-app-name=torbrowser
	mozconfig_annotate 'torbrowser' --with-app-basename=torbrowser
	echo "mk_add_options MOZ_APP_DISPLAYNAME=TorBrowser" >> "${S}"/.mozconfig

	# Finalize and report settings
	mozconfig_final

	if [[ $(gcc-major-version) -lt 4 ]]; then
		append-cxxflags -fno-stack-protector
	elif [[ $(gcc-major-version) -gt 4 || $(gcc-minor-version) -gt 3 ]]; then
		if use amd64 || use x86; then
			append-flags -mno-avx
		fi
	fi
}

src_compile() {
	CC="$(tc-getCC)" CXX="$(tc-getCXX)" LD="$(tc-getLD)" \
	MOZ_MAKE_FLAGS="${MAKEOPTS}" \
	emake -f client.mk
	if [ $? -ne 0 ]; then
		ewarn "Build has failed, please see https://bugs.gentoo.org/show_bug.cgi?id=465728 for"
		ewarn "possible solutions such as MAKEOPTS=-j1"
		die
	fi
}

src_install() {
	MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}/${MY_PN}"
	DICTPATH="\"${EPREFIX}/usr/share/myspell\""

	# MOZ_BUILD_ROOT, and hence OBJ_DIR change depending on arch, compiler etc.
	local obj_dir="$(echo */config.log)"
	obj_dir="${obj_dir%/*}"
	cd "${S}/${obj_dir}"

	# Without methodjit and tracejit there's no conflict with PaX
	if use jit; then
		# Pax mark xpcshell for hardened support, only used for startupcache creation.
		pax-mark m "${S}/${obj_dir}"/dist/bin/xpcshell
	fi

	# Add torbrowser default prefs
	cp "${WORKDIR}/omni/defaults/preferences/#tor.js" \
		"${S}/${obj_dir}/dist/bin/defaults/preferences/all-gentoo.js" || die

	# Set default homepage
	cp "${WORKDIR}/omni/chrome/en-US/locale/branding/browserconfig.properties" \
		"${S}/${obj_dir}/dist/bin/chrome/en-US/locale/branding/browserconfig.properties" || die

	# Set default path to search for dictionaries.
	echo "pref(\"spellchecker.dictionary_path\", ${DICTPATH});" \
		>> "${S}/${obj_dir}/dist/bin/defaults/preferences/all-gentoo.js" || die

	MOZ_MAKE_FLAGS="${MAKEOPTS}" \
	emake DESTDIR="${D}" install || die "emake install failed"

	# Install icons and .desktop for menu entry
	local size sizes icon_path
	sizes="16 24 32 48 256"
	icon_path="${FILESDIR}/branding"
	for size in ${sizes}; do
		newicon -s ${size} "${icon_path}/default${size}.png" ${PN}.png
	done
	# The 128x128 icon has a different name
	newicon -s 128 "${icon_path}/mozicon128.png" ${PN}.png
	make_desktop_entry ${PN} "TorBrowser" ${PN} "Network;WebBrowser"

	# Add StartupNotify=true bug 237317
	if use startup-notification ; then
		echo "StartupNotify=true" >> "${ED}/usr/share/applications/${PN}-${PN}.desktop"
	fi

	# Without methodjit and tracejit there's no conflict with PaX
	if use jit; then
		# Required in order to use plugins and even run firefox on hardened.
		pax-mark m "${ED}"${MOZILLA_FIVE_HOME}/{torbrowser,torbrowser-bin}
	fi

	# Plugin-container needs to be pax-marked for hardened to ensure plugins such as flash
	# continue to work as expected.
	pax-mark m "${ED}"${MOZILLA_FIVE_HOME}/plugin-container

	# Plugins dir
	keepdir /usr/$(get_libdir)/${PN}/${MY_PN}/plugins

	# we dont want development files
	rm -rf "${ED}"/usr/include "${ED}${MOZILLA_FIVE_HOME}"/{idl,include,lib,sdk} || \
		die "Failed to remove sdk and headers"

	# Profile
	insinto ${MOZILLA_FIVE_HOME}/defaults
	doins -r "${WORKDIR}"/tor-browser_en-US/Data/profile
	dodoc "${WORKDIR}"/tor-browser_en-US/Docs/changelog
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	ewarn ""
	ewarn "This patched firefox build is _NOT_ recommended by TOR upstream but uses"
	ewarn "the exact same patches. Use this only if you know what you are doing!"
	ewarn ""
	ewarn "The profile moved to ~/.mozilla/torbrowser. It's auto generated"
	ewarn "and manually copying isn't necessary anymore."
	ewarn ""
	elog "Torbrowser uses port 9150 to connect to Tor. You can change the port"
	elog "in the connection settings to match your setup."

	# Update mimedb for the new .desktop file
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
