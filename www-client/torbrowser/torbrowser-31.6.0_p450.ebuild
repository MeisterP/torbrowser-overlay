# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
WANT_AUTOCONF="2.1"
MOZ_ESR="1"

MY_PN="firefox"
if [[ ${MOZ_ESR} == 1 ]]; then
	# ESR releases have slightly version numbers
	MOZ_PV="${PV/_p*}esr"
fi

# see https://gitweb.torproject.org/builders/tor-browser-bundle.git/tree/gitian/versions
TOR_PV="4.5"
GIT_TAG="tor-browser-${MOZ_PV}-4.5-1-build3"

# Patch version
PATCH="${MY_PN}-31.0-patches-0.2"

MOZCONFIG_OPTIONAL_WIFI=1
MOZCONFIG_OPTIONAL_JIT="enabled"

inherit check-reqs flag-o-matic toolchain-funcs eutils gnome2-utils mozconfig-v5.31 multilib pax-utils autotools

DESCRIPTION="The Tor Browser"
HOMEPAGE="https://www.torproject.org/projects/torbrowser.html
	https://gitweb.torproject.org/tor-browser.git"

KEYWORDS="~amd64 ~x86"
SLOT="0"
# BSD license applies to torproject-related code like the patches
# icons are under CCPL-Attribution-3.0
LICENSE="BSD CC-BY-3.0 MPL-2.0 GPL-2 LGPL-2.1"
IUSE="hardened test"

BASE_SRC_URI="https://dist.torproject.org/${PN}/${TOR_PV}"
ARCHIVE_SRC_URI="https://archive.torproject.org/tor-package-archive/${PN}/${TOR_PV}"
SRC_URI="https://gitweb.torproject.org/tor-browser.git/snapshot/${GIT_TAG}.tar.gz -> ${GIT_TAG}.tar.gz
	http://dev.gentoo.org/~anarchy/mozilla/patchsets/${PATCH}.tar.xz
	http://dev.gentoo.org/~axs/distfiles/${PATCH}.tar.xz
	x86? (
		${BASE_SRC_URI}/tor-browser-linux32-${TOR_PV}_en-US.tar.xz
		${ARCHIVE_SRC_URI}/tor-browser-linux32-${TOR_PV}_en-US.tar.xz
	)
	amd64? (
		${BASE_SRC_URI}/tor-browser-linux64-${TOR_PV}_en-US.tar.xz
		${ARCHIVE_SRC_URI}/tor-browser-linux64-${TOR_PV}_en-US.tar.xz
	)"

ASM_DEPEND=">=dev-lang/yasm-1.1"

CDEPEND=">=dev-libs/nss-3.17.1
	>=dev-libs/nspr-4.10.6"

DEPEND="${CDEPEND}
	amd64? ( ${ASM_DEPEND}
		virtual/opengl )
	x86? ( ${ASM_DEPEND}
		virtual/opengl )"

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
}

pkg_pretend() {
	# Ensure we have enough disk space to compile
	if use debug || use test ; then
		CHECKREQS_DISK_BUILD="8G"
	else
		CHECKREQS_DISK_BUILD="4G"
	fi
	check-reqs_pkg_setup

	if use jit && [[ -n ${PROFILE_IS_HARDENED} ]]; then
		ewarn "You are emerging this package on a hardened profile with USE=jit enabled."
		ewarn "This is horribly insecure as it disables all PAGEEXEC restrictions."
		ewarn "Please ensure you know what you are doing.  If you don't, please consider"
		ewarn "emerging the package with USE=-jit"
	fi
}

src_prepare() {
	# Apply gentoo firefox patches
	EPATCH_SUFFIX="patch" \
	EPATCH_FORCE="yes" \
	epatch "${WORKDIR}/firefox"

	# Revert "Change the default Firefox profile directory to be TBB-relative"
	epatch -R "${FILESDIR}/4.5-Change_the_default_Firefox_profile_directory_to_be_TBB-relative.patch"

	# FIXME: https://trac.torproject.org/projects/tor/ticket/10925
	# Except lightspark-plugin from blocklist
	epatch "${FILESDIR}"/${PN}-24.3.0-allow-lightspark.patch

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
		-i "${S}"/nsprpub/configure{.in,} \
		|| die

	# Don't exit with error when some libs are missing which we have in
	# system.
	sed '/^MOZ_PKG_FATAL_WARNINGS/s@= 1@= 0@' \
		-i "${S}"/browser/installer/Makefile.in || die

	# Don't error out when there's no files to be removed:
	sed 's@\(xargs rm\)$@\1 -f@' \
		-i "${S}"/toolkit/mozapps/installer/packager.mk || die

	eautoreconf

	# Must run autoconf in js/src
	cd "${S}"/js/src || die
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

	# Add full relro support for hardened
	use hardened && append-ldflags "-Wl,-z,relro,-z,now"

	mozconfig_annotate '' --enable-extensions="${MEXTENSIONS}"
	mozconfig_annotate '' --disable-mailnews

	# Other ff-specific settings
	mozconfig_annotate '' --with-default-mozilla-five-home=${MOZILLA_FIVE_HOME}

	# Rename the install directory and the executable
	mozconfig_annotate 'torbrowser' --libdir="${EPREFIX}"/usr/$(get_libdir)/${PN}
	mozconfig_annotate 'torbrowser' --with-app-name=torbrowser
	mozconfig_annotate 'torbrowser' --with-app-basename=torbrowser
	# see https://gitweb.torproject.org/tor-browser.git/tree/configure.in?h=tor-browser-31.6.0esr-4.5-1#n6395
	mozconfig_annotate 'torbrowser' --disable-tor-browser-update
	mozconfig_annotate 'torbrowser' --with-tor-browser-version=${TOR_PV}

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
	emake -f client.mk
}

src_install() {
	MOZILLA_FIVE_HOME="${EPREFIX}"/usr/$(get_libdir)/${PN}/${MY_PN}
	DICTPATH="\"${EPREFIX}/usr/share/myspell\""

	# MOZ_BUILD_ROOT, and hence OBJ_DIR change depending on arch, compiler etc.
	local obj_dir="$(echo */config.log)"
	obj_dir="${obj_dir%/*}"
	cd "${S}/${obj_dir}" || die

	# Pax mark xpcshell for hardened support, only used for startupcache creation.
	pax-mark m "${S}/${obj_dir}"/dist/bin/xpcshell

	# Add an emty default prefs for mozconfig-3.eclass
	touch "${S}/${obj_dir}/dist/bin/browser/defaults/preferences/all-gentoo.js" \
		|| die

	# Set default path to search for dictionaries.
	echo "pref(\"spellchecker.dictionary_path\", ${DICTPATH});" \
		>> "${S}/${obj_dir}/dist/bin/browser/defaults/preferences/all-gentoo.js" \
		|| die

	# see: https://gitweb.torproject.org/builders/tor-browser-bundle.git/tree/gitian/descriptors/linux/gitian-bundle.yml#n150
	echo "pref(\"general.useragent.locale\", \"en-US\");" \
		>> "${S}/${obj_dir}/dist/bin/browser/defaults/preferences/000-tor-browser.js" \
		|| die

	MOZ_MAKE_FLAGS="${MAKEOPTS}" \
	emake DESTDIR="${D}" install

	# Install icons and .desktop for menu entry
	local size sizes icon_path
	sizes="16 24 32 48 256"
	icon_path="${S}/browser/branding/official"
	for size in ${sizes}; do
		newicon -s ${size} "${icon_path}/default${size}.png" ${PN}.png
	done
	# The 128x128 icon has a different name
	newicon -s 128 "${icon_path}/mozicon128.png" ${PN}.png
	make_desktop_entry ${PN} "Tor Browser" ${PN} "Network;WebBrowser" "StartupWMClass=Torbrowser"

	# Add StartupNotify=true bug 237317
	if use startup-notification ; then
		echo "StartupNotify=true" \
			>> "${ED}/usr/share/applications/${PN}-${PN}.desktop" \
			|| die
	fi

	# Required in order to use plugins and even run torbrowser on hardened.
	pax-mark m "${ED}"${MOZILLA_FIVE_HOME}/plugin-container
	# Required in order for jit to work on hardened, as of torbroser-31
	use jit && pax-mark pm "${ED}"${MOZILLA_FIVE_HOME}/{torbrowser,torbrowser-bin}

	# We dont want development files
	rm -r "${ED}"/usr/include "${ED}${MOZILLA_FIVE_HOME}"/{idl,include,lib,sdk} \
		|| die "Failed to remove sdk and headers"

	# revdep-rebuild entry
	insinto /etc/revdep-rebuild
	echo "SEARCH_DIRS_MASK=${MOZILLA_FIVE_HOME}" >> ${T}/10${PN}
	doins "${T}"/10${PN} || die

	# Profile without the tor-launcher extension
	# see: https://trac.torproject.org/projects/tor/ticket/10160
	local profile_dir="${WORKDIR}/tor-browser_en-US/Browser/TorBrowser/Data/Browser/profile.default"

	docompress -x "${EROOT}/usr/share/doc/${PF}/tor-launcher@torproject.org.xpi"
	dodoc "${profile_dir}/extensions/tor-launcher@torproject.org.xpi"
	rm "${profile_dir}/extensions/tor-launcher@torproject.org.xpi" || die "Failed to remove torlauncher extension"

	insinto ${MOZILLA_FIVE_HOME}/browser/defaults/profile
	doins -r "${profile_dir}"/{extensions,preferences,bookmarks.html}

	# see: https://gitweb.torproject.org/builders/tor-browser-bundle.git/tree/RelativeLink/start-tor-browser#n301
	dodoc "${FILESDIR}/README.tor-launcher"
	dodoc "${WORKDIR}/tor-browser_en-US/Browser/TorBrowser/Docs/ChangeLog.txt"

	# see: https://trac.torproject.org/projects/tor/ticket/11751#comment:2
	dodoc "${FILESDIR}/99torbrowser.example"
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	echo
	ewarn "This patched firefox build is _NOT_ recommended by Tor upstream but uses"
	ewarn "the exact same sources. Use this only if you know what you are doing!"
	elog ""
	elog "Torbrowser uses port 9150 to connect to Tor. You can change the port"
	elog "in the connection settings to match your setup."
	elog ""
	elog "To get the advanced functionality of Torbutton (network information,"
	elog "new identity), Torbrowser needs to access a control port."
	elog "See 99torbrowser.example in /usr/share/doc/${PF} and check \"man tor\""
	elog "for further information."
	echo

	if [[ "${REPLACING_VERSIONS}" ]] && [[ "${REPLACING_VERSIONS}" < "31.6.0_p450" ]]; then
		ewarn ""
		ewarn "Since this is a major upgrade, you need to start with a fresh profile."
		ewarn "Either move or remove your profile in \"~/.mozilla/torbrowser/\""
		ewarn "and let Torbrowser generate a new one."
		echo
	fi

	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
