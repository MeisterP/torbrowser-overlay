# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
WANT_AUTOCONF="2.1"
MOZ_ESR=1

MY_PN="firefox"
if [[ ${MOZ_ESR} == 1 ]]; then
	# ESR releases have slightly different version numbers
	MOZ_PV="${PV/_p*}esr"
fi

# see https://gitweb.torproject.org/builders/tor-browser-bundle.git/tree/gitian/versions?h=maint-6.0
TOR_PV="6.0.8"
EGIT_COMMIT="tor-browser-${MOZ_PV}-6.0-1-build1"

# Patch version
PATCH="${MY_PN}-45.0-patches-08"

# Kill gtk3 support since gtk+-3.20 breaks it hard prior to 48.0
#MOZCONFIG_OPTIONAL_GTK3=1
MOZCONFIG_OPTIONAL_WIFI=1
MOZCONFIG_OPTIONAL_JIT="enabled"

inherit git-r3 check-reqs flag-o-matic toolchain-funcs eutils gnome2-utils mozconfig-v6.45 pax-utils autotools

DESCRIPTION="The Tor Browser"
HOMEPAGE="https://www.torproject.org/projects/torbrowser.html
	https://gitweb.torproject.org/tor-browser.git"

KEYWORDS="~amd64 ~x86"
SLOT="0"
# BSD license applies to torproject-related code like the patches
# icons are under CCPL-Attribution-3.0
LICENSE="BSD CC-BY-3.0 MPL-2.0 GPL-2 LGPL-2.1"
IUSE="hardened test"

EGIT_REPO_URI="https://git.torproject.org/tor-browser.git"
EGIT_CLONE_TYPE="shallow"
BASE_SRC_URI="https://dist.torproject.org/${PN}/${TOR_PV}"
ARCHIVE_SRC_URI="https://archive.torproject.org/tor-package-archive/${PN}/${TOR_PV}"
SRC_URI="https://dev.gentoo.org/~anarchy/mozilla/patchsets/${PATCH}.tar.xz
	https://dev.gentoo.org/~axs/mozilla/patchsets/${PATCH}.tar.xz
	https://dev.gentoo.org/~polynomial-c/mozilla/patchsets/${PATCH}.tar.xz
	x86? (
		${BASE_SRC_URI}/tor-browser-linux32-${TOR_PV}_en-US.tar.xz
		${ARCHIVE_SRC_URI}/tor-browser-linux32-${TOR_PV}_en-US.tar.xz
	)
	amd64? (
		${BASE_SRC_URI}/tor-browser-linux64-${TOR_PV}_en-US.tar.xz
		${ARCHIVE_SRC_URI}/tor-browser-linux64-${TOR_PV}_en-US.tar.xz
	)"

ASM_DEPEND=">=dev-lang/yasm-1.1"

RDEPEND=">=dev-libs/nss-3.21.1
	>=dev-libs/nspr-4.12"

DEPEND="${RDEPEND}
	${ASM_DEPEND}
	virtual/opengl"

QA_PRESTRIPPED="usr/lib*/${PN}-1/${PN}/torbrowser"

BUILD_OBJ_DIR="${S}/ff"

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
}

src_unpack() {
	unpack ${A}
	git-r3_src_unpack
}

src_prepare() {
	# Apply gentoo firefox patches
	# FIXME: fails to apply
	rm "${WORKDIR}/firefox/8012-binutils-2.26-gold-elfhack.patch" || die
	eapply "${WORKDIR}/firefox"

	# Revert "Change the default Firefox profile directory to be TBB-relative"
	eapply "${FILESDIR}/${PN}-45.4.0-Change_the_default_Firefox_profile_directory.patch"

	# FIXME: https://trac.torproject.org/projects/tor/ticket/10925
	# Except lightspark-plugin and freshplayer-plugin from blocklist
	eapply "${FILESDIR}/${PN}-45.4.0-allow-lightspark-and-freshplayerplugin.patch"

	# FIXME: prevent warnings in bundled nss
	eapply "${FILESDIR}/${PN}-45.4.0-nss-fixup-warnings.patch"

	# Allow user to apply any additional patches without modifing ebuild
	eapply_user

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

	# Keep codebase the same even if not using official branding
	sed '/^MOZ_DEV_EDITION=1/d' \
		-i "${S}"/browser/branding/aurora/configure.sh || die

	eautoreconf

	# Must run autoconf in js/src
	cd "${S}"/js/src || die
	eautoconf

	# Need to update jemalloc's configure
	cd "${S}"/memory/jemalloc/src || die
	WANT_AUTOCONF= eautoconf
}

src_configure() {
	MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}-1/${PN}"
	MEXTENSIONS="default"

	mozconfig_init
	mozconfig_config

	# Add full relro support for hardened
	use hardened && append-ldflags "-Wl,-z,relro,-z,now"

	mozconfig_annotate '' --enable-extensions="${MEXTENSIONS}"
	mozconfig_annotate '' --disable-mailnews

	# Other ff-specific settings
	mozconfig_annotate '' --with-default-mozilla-five-home=${MOZILLA_FIVE_HOME}

	# Rename the install directory and the executable
	mozconfig_annotate 'torbrowser' --libdir=/usr/$(get_libdir)/${PN}-1
	mozconfig_annotate 'torbrowser' --with-app-name=torbrowser
	mozconfig_annotate 'torbrowser' --with-app-basename=torbrowser
	# see https://gitweb.torproject.org/tor-browser.git/tree/configure.in/?h=tor-browser-45.1.1esr-6.0-1#n6519
	mozconfig_annotate 'torbrowser' --disable-tor-browser-update
	mozconfig_annotate 'torbrowser' --with-tor-browser-version=${TOR_PV}
	#mozconfig_annotate 'torbrowser' --enable-tor-browser-data-outside-app-dir

	# torbrowser uses a patched nss library
	# see https://gitweb.torproject.org/tor-browser.git/log/security/nss?h=tor-browser-45.1.1esr-6.0-1
	mozconfig_annotate 'torbrowser' --without-system-nspr
	mozconfig_annotate 'torbrowser' --without-system-nss

	echo "mk_add_options MOZ_OBJDIR=${BUILD_OBJ_DIR}" >> "${S}"/.mozconfig

	# Finalize and report settings
	mozconfig_final

	if [[ $(gcc-major-version) -lt 4 ]]; then
		append-cxxflags -fno-stack-protector
	fi

	# workaround for funky/broken upstream configure...
	emake -f client.mk configure
}

src_compile() {
	CC="$(tc-getCC)" CXX="$(tc-getCXX)" LD="$(tc-getLD)" \
	MOZ_MAKE_FLAGS="${MAKEOPTS}" SHELL="${SHELL:-${EPREFIX%/}/bin/bash}" \
	emake -f client.mk realbuild
}

src_install() {
	MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}-1/${PN}"

	cd "${BUILD_OBJ_DIR}" || die

	# Pax mark xpcshell for hardened support, only used for startupcache creation.
	pax-mark m "${BUILD_OBJ_DIR}"/dist/bin/xpcshell

	# Add an emty default prefs for mozconfig-v6.45.eclass:
	touch "${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" \
		|| die

	mozconfig_install_prefs \
		"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js"

	# see: https://gitweb.torproject.org/builders/tor-browser-bundle.git/tree/gitian/descriptors/linux/gitian-bundle.yml?h=maint-6.0#n160
	touch "${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/extension-overrides.js" \
		|| die

	# see: https://gitweb.torproject.org/builders/tor-browser-bundle.git/tree/gitian/descriptors/linux/gitian-bundle.yml?h=maint-6.0#n169
	echo "pref(\"extensions.torlauncher.prompt_for_locale\", \"false\");" \
		>> "${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/extension-overrides.js" \
		|| die

	echo "pref(\"intl.locale.matchOS\", \"false\");" \
		>> "${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/extension-overrides.js" \
		|| die

	# see: https://gitweb.torproject.org/builders/tor-browser-bundle.git/tree/gitian/descriptors/linux/gitian-bundle.yml?h=maint-6.0#n201
	echo "pref(\"general.useragent.locale\", \"en-US\");" \
		>> "${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/000-tor-browser.js" \
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

	# Required in order to use plugins and even run torbrowser on hardened, with jit useflag.
	if use jit; then
		pax-mark m "${ED}"${MOZILLA_FIVE_HOME}/{torbrowser,torbrowser-bin,plugin-container}
	else
		pax-mark m "${ED}"${MOZILLA_FIVE_HOME}/plugin-container
	fi

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
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		ewarn "This patched firefox build is _NOT_ recommended by Tor upstream but uses"
		ewarn "the exact same sources. Use this only if you know what you are doing!"
		elog "Torbrowser uses port 9150 to connect to Tor. You can change the port"
		elog "in the connection settings to match your setup."
		elog ""
		elog "To get the advanced functionality of Torbutton (network information,"
		elog "new identity), Torbrowser needs to access a control port."
		elog "See 99torbrowser.example in /usr/share/doc/${PF} and"
		elog "https://github.com/MeisterP/torbrowser-overlay/blob/master/Readme.md"
		elog "for further information."
	fi

	if [[ "${REPLACING_VERSIONS}" ]] && [[ "${REPLACING_VERSIONS}" < "45.1.1_p600" ]]; then
		ewarn "Since this is a major upgrade, you need to start with a fresh profile."
		ewarn "Either move or remove your profile in \"~/.mozilla/torbrowser/\""
		ewarn "and let Torbrowser generate a new one."
	fi

	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
