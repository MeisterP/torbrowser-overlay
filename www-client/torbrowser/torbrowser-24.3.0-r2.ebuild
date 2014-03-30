# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
WANT_AUTOCONF="2.1"
MOZ_ESR="1"

MY_PN="firefox"
TOR_PV="3.5.2.1"
if [[ ${MOZ_ESR} == 1 ]]; then
	# ESR releases have slightly version numbers
	MOZ_PV="${PV}esr"
fi
GIT_TAG="tor-browser-${MOZ_PV}-${TOR_PV}-build2"

# Patch version
PATCH="${MY_PN}-24.0-patches-0.9"

inherit check-reqs flag-o-matic toolchain-funcs eutils gnome2-utils mozconfig-3 multilib pax-utils autotools

DESCRIPTION="The Tor Browser"
HOMEPAGE="https://www.torproject.org/projects/torbrowser.html
	https://gitweb.torproject.org/tor-browser.git"

KEYWORDS="~amd64 ~x86"
SLOT="0"
# BSD license applies to torproject-related code like the patches
# icons are under CCPL-Attribution-3.0
LICENSE="BSD CC-BY-3.0 MPL-2.0 GPL-2 LGPL-2.1"
IUSE="gstreamer +jit pulseaudio selinux system-cairo system-icu system-jpeg system-sqlite"

BASE_SRC_URI="https://www.torproject.org/dist/${PN}/${TOR_PV}"
SRC_URI="https://gitweb.torproject.org/tor-browser.git/snapshot/${GIT_TAG}.tar.gz -> ${GIT_TAG}.tar.gz
	http://dev.gentoo.org/~anarchy/mozilla/patchsets/${PATCH}.tar.xz
	http://dev.gentoo.org/~nirbheek/mozilla/patchsets/${PATCH}.tar.xz
	x86? ( ${BASE_SRC_URI}/tor-browser-linux32-${TOR_PV}_en-US.tar.xz )
	amd64? ( ${BASE_SRC_URI}/tor-browser-linux64-${TOR_PV}_en-US.tar.xz )"

ASM_DEPEND=">=dev-lang/yasm-1.1"

# Mesa 7.10 needed for WebGL + bugfixes
RDEPEND="
	>=dev-libs/nss-3.15.3
	>=dev-libs/nspr-4.10.2
	>=dev-libs/glib-2.26:2
	>=media-libs/mesa-7.10
	>=media-libs/libpng-1.5.13[apng]
	virtual/libffi
	gstreamer? ( media-plugins/gst-plugins-meta:0.10[ffmpeg] )
	pulseaudio? ( media-sound/pulseaudio )
	system-cairo? ( >=x11-libs/cairo-1.12[X] )
	system-icu? ( >=dev-libs/icu-0.51.1 )
	system-jpeg? ( >=media-libs/libjpeg-turbo-1.2.1 )
	system-sqlite? ( >=dev-db/sqlite-3.7.17:3[secure-delete,debug=] )
	>=media-libs/libvpx-1.0.0
	kernel_linux? ( media-libs/alsa-lib )
	selinux? ( sec-policy/selinux-mozilla )"

DEPEND="${RDEPEND}
	>=sys-devel/binutils-2.16.1
	virtual/pkgconfig
	amd64? ( ${ASM_DEPEND}
		virtual/opengl )
	x86? ( ${ASM_DEPEND}
		virtual/opengl )
	!www-misc/torbrowser-profile"

QA_PRESTRIPPED="usr/$(get_libdir)/${PN}/${MY_PN}/firefox"

S="${WORKDIR}/${GIT_TAG}"

# See mozcoreconf-2.eclass
mozversion_is_new_enough() {
	if [[ $(get_version_component_range 1) -ge 17 ]] ; then
		return 0
	fi
	return 1
}

pkg_setup() {
	moz_pkgsetup

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
	# We can't use vcs-snapshot.eclass becaus not all sources are snapshots
	mv "${WORKDIR}"/tor-browser-"${GIT_TAG}"-[0-9a-f]*[0-9a-f]/ "${WORKDIR}/${GIT_TAG}" || die
}

src_prepare() {
	# Revert "Change the default Firefox profile directory to be TBB-relative"
	epatch -R "${FILESDIR}/tor-browser.git-6662aae388094c7cca535e34f24ef01af7d51481.patch"

	# FIXME: https://trac.torproject.org/projects/tor/ticket/10925
	# Allow lightspark as well
	epatch "${FILESDIR}"/${P}-allow-lightspark.patch

	# Apply gentoo firefox patches
	EPATCH_SUFFIX="patch" \
	EPATCH_FORCE="yes" \
	epatch "${WORKDIR}/firefox"

	# Allow user to apply any additional patches without modifing ebuild
	epatch_user

	# Enable gnomebreakpad
	if use debug ; then
		sed -i -e "s:GNOME_DISABLE_CRASH_DIALOG=1:GNOME_DISABLE_CRASH_DIALOG=0:g" \
			"${S}"/build/unix/run-mozilla.sh || die "sed failed!"
	fi

	# Ensure that our plugins dir is enabled as default
	sed -i -e "s:/usr/lib/mozilla/plugins:/usr/lib/nsbrowser/plugins:" \
		"${S}"/xpcom/io/nsAppFileLocationProvider.cpp || die "sed failed to replace plugin path for 32bit!"
	sed -i -e "s:/usr/lib64/mozilla/plugins:/usr/lib64/nsbrowser/plugins:" \
		"${S}"/xpcom/io/nsAppFileLocationProvider.cpp || die "sed failed to replace plugin path for 64bit!"

	# Fix sandbox violations during make clean, bug 372817
	sed -e "s:\(/no-such-file\):${T}\1:g" \
		-i "${S}"/config/rules.mk \
		-i "${S}"/js/src/config/rules.mk \
		-i "${S}"/nsprpub/configure{.in,} \
		|| die

	# Don't exit with error when some libs are missing which we have in system.
	sed '/^MOZ_PKG_FATAL_WARNINGS/s@= 1@= 0@' \
		-i "${S}"/browser/installer/Makefile.in || die

	# Don't error out when there's no files to be removed:
	sed 's@\(xargs rm\)$@\1 -f@' \
		-i "${S}"/toolkit/mozapps/installer/packager.mk || die

	eautoreconf

	# Must run autoconf in js/src
	cd "${S}"/js/src
	eautoconf
}

src_configure() {
	MOZILLA_FIVE_HOME="${EPREFIX}"/usr/$(get_libdir)/${PN}/${MY_PN}
	MEXTENSIONS="default"

	####################################
	#
	# mozconfig, CFLAGS and CXXFLAGS setup
	#
	####################################

	mozconfig_init
	mozconfig_config

	# We must force enable jemalloc 3 threw .mozconfig
	echo "export MOZ_JEMALLOC=1" >> ${S}/.mozconfig

	mozconfig_annotate '' --enable-jemalloc
	mozconfig_annotate '' --enable-replace-malloc
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
	mozconfig_use_enable pulseaudio
	mozconfig_use_enable system-cairo
	mozconfig_use_enable system-sqlite
	mozconfig_use_with system-jpeg
	mozconfig_use_with system-icu
	mozconfig_use_enable system-icu intl-api
	# Feature is know to cause problems on hardened
	mozconfig_use_enable jit ion

	# Rename the executable
	mozconfig_annotate 'torbrowser' --with-app-name=torbrowser
	mozconfig_annotate 'torbrowser' --with-app-basename=torbrowser

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
	MOZ_MAKE_FLAGS="${MAKEOPTS}" SHELL="${SHELL}" \
	emake -f client.mk || die "emake failed"
}

src_install() {
	MOZILLA_FIVE_HOME="${EPREFIX}"/usr/$(get_libdir)/${PN}/${MY_PN}
	DICTPATH="\"${EPREFIX}/usr/share/myspell\""

	# MOZ_BUILD_ROOT, and hence OBJ_DIR change depending on arch, compiler etc.
	local obj_dir="$(echo */config.log)"
	obj_dir="${obj_dir%/*}"
	cd "${S}/${obj_dir}"

	# Pax mark xpcshell for hardened support, only used for startupcache creation.
	pax-mark m "${S}/${obj_dir}"/dist/bin/xpcshell

	# Add an emty default prefs for mozconfig-3.eclass
	touch "${S}/${obj_dir}/dist/bin/browser/defaults/preferences/all-gentoo.js" || die

	# Add torbrowser version and disable the flash-plugin by default
	# see https://gitweb.torproject.org/builders/tor-browser-bundle.git/blob/HEAD:/gitian/versions
	# see https://gitweb.torproject.org/builders/tor-browser-bundle.git/blob/HEAD:/gitian/mkbundle-linux.sh#l40
	# see https://gitweb.torproject.org/builders/tor-browser-bundle.git/blob/HEAD:/gitian/descriptors/linux/gitian-firefox.yml#l76
	grep -v -e '^pref(\"torbrowser.version\",' -e '^pref(\"plugin.state.flash\",' \
		"${S}/${obj_dir}/dist/bin/browser/defaults/preferences/000-tor-browser.js" \
		> "${S}/${obj_dir}/dist/bin/browser/defaults/preferences/000-tor-browser.js.fixed" || die
	mv "${S}/${obj_dir}"/dist/bin/browser/defaults/preferences/000-tor-browser.js{.fixed,} || die

	# Set torbrowser version
	echo "pref(\"torbrowser.version\", \"$TOR_PV-Linux\");" \
		>> "${S}/${obj_dir}/dist/bin/browser/defaults/preferences/000-tor-browser.js" || die

	# Disable adobe-flash by default
	echo "pref(\"plugin.state.flash\", 0);" \
		>> "${S}/${obj_dir}/dist/bin/browser/defaults/preferences/000-tor-browser.js" || die

	# Set default path to search for dictionaries.
	echo "pref(\"spellchecker.dictionary_path\", ${DICTPATH});" \
		>> "${S}/${obj_dir}/dist/bin/browser/defaults/preferences/all-gentoo.js" || die

	if ! use libnotify; then
		echo "pref(\"browser.download.manager.showAlertOnComplete\", false);" \
			>> "${S}/${obj_dir}/dist/bin/browser/defaults/preferences/all-gentoo.js" || die
	fi

	MOZ_MAKE_FLAGS="${MAKEOPTS}" \
	emake DESTDIR="${D}" install || die "emake install failed"

	local size sizes icon_path
	sizes="16 24 32 48 256"
	icon_path="${S}/browser/branding/official"

	# Install icons and .desktop for menu entry
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

	# Required in order to use plugins and even run torbrowser on hardened.
	pax-mark m "${ED}"${MOZILLA_FIVE_HOME}/{torbrowser,torbrowser-bin,plugin-container}

	# We dont want development files
	rm -rf "${ED}"/usr/include "${ED}${MOZILLA_FIVE_HOME}"/{idl,include,lib,sdk} || die

	# FIXME: https://trac.torproject.org/projects/tor/ticket/10160
	# Profile without the tor-launcher extension
	local torlauncher="${WORKDIR}/tor-browser_en-US/Data/Browser/profile.default/extensions/tor-launcher@torproject.org.xpi"
	dodoc "${torlauncher}" && rm -rf "${torlauncher}" || die

	dodoc "${WORKDIR}/tor-browser_en-US/Docs/ChangeLog.txt"

	insinto ${MOZILLA_FIVE_HOME}/browser/defaults/profile
	doins -r "${WORKDIR}"/tor-browser_en-US/Data/Browser/profile.default/{extensions,preferences,bookmarks.html}

	# FIXME: https://trac.torproject.org/projects/tor/ticket/10606
	# about:tor always reports connected (part of torbutton)
	# Set the default homepag here since we need to overwrite extension prefs
	echo "user_pref(\"browser.startup.homepage\", \"https://check.torproject.org/\");" \
		> "${T}/prefs.js" || die
	doins "${T}/prefs.js"
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	ewarn ""
	ewarn "This patched firefox build is _NOT_ recommended by Tor upstream but uses"
	ewarn "the exact same sources. Use this only if you know what you are doing!"
	ewarn ""
	elog "Torbrowser uses port 9150 to connect to Tor. You can change the port"
	elog "in the connection settings to match your setup."

	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
