# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
WANT_AUTOCONF="2.1"
MOZ_ESR="1"

PYTHON_COMPAT=( python3_{5,6,7} )
PYTHON_REQ_USE='ncurses,sqlite,ssl,threads(+)'

MY_PN="firefox"
if [[ ${MOZ_ESR} == 1 ]]; then
	# ESR releases have slightly different version numbers
	MOZ_PV="${PV/_p*}esr"
fi

# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/firefox/config?h=maint-8.0#n4
TOR_PV="8.0.2"
TOR_COMMIT="tor-browser-${MOZ_PV}-${TOR_PV%.*}-1-build1"

# Patch version
PATCH="${MY_PN}-60.0-patches-03"

inherit check-reqs flag-o-matic toolchain-funcs eutils gnome2-utils llvm \
		mozconfig-v6.60 pax-utils autotools

DESCRIPTION="The Tor Browser"
HOMEPAGE="https://www.torproject.org/projects/torbrowser.html
	https://gitweb.torproject.org/tor-browser.git"

KEYWORDS="~amd64 ~x86"

SLOT="0"
# BSD license applies to torproject-related code like the patches
# icons are under CCPL-Attribution-3.0
LICENSE="BSD CC-BY-3.0 MPL-2.0 GPL-2 LGPL-2.1"
IUSE="hardened"

BASE_SRC_URI="https://dist.torproject.org/${PN}/${TOR_PV}"
ARCHIVE_SRC_URI="https://archive.torproject.org/tor-package-archive/${PN}/${TOR_PV}"

PATCH_URIS=( https://dev.gentoo.org/~whissi/dist/firefox/${PATCH}.tar.xz https://dev.gentoo.org/~{anarchy,axs,polynomial-c}/mozilla/patchsets/${PATCH}.tar.xz )
SRC_URI="${SRC_URI}
	https://gitweb.torproject.org/tor-browser.git/snapshot/${TOR_COMMIT}.tar.gz -> ${TOR_COMMIT}.tar.gz
	x86? ( ${BASE_SRC_URI}/tor-browser-linux32-${TOR_PV}_en-US.tar.xz
		${ARCHIVE_SRC_URI}/tor-browser-linux32-${TOR_PV}_en-US.tar.xz )
	amd64? ( ${BASE_SRC_URI}/tor-browser-linux64-${TOR_PV}_en-US.tar.xz
		${ARCHIVE_SRC_URI}/tor-browser-linux64-${TOR_PV}_en-US.tar.xz )
	${PATCH_URIS[@]}"

ASM_DEPEND=">=dev-lang/yasm-1.1"

RDEPEND="
	system-icu? ( >=dev-libs/icu-60.2 )
	>=dev-libs/nss-3.36.4
	>=dev-libs/nspr-4.19"

DEPEND="${RDEPEND}
	>=sys-devel/llvm-4.0.1
	>=sys-devel/clang-4.0.1
	amd64? ( ${ASM_DEPEND} virtual/opengl )
	x86? ( ${ASM_DEPEND} virtual/opengl )"

QA_PRESTRIPPED="usr/lib*/${PN}/torbrowser"

BUILD_OBJ_DIR="${S}/ff"

llvm_check_deps() {
	has_version "sys-devel/clang:${LLVM_SLOT}"
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

	addpredict /proc/self/oom_score_adj

	llvm_pkg_setup
}

pkg_pretend() {
	# Ensure we have enough disk space to compile
	CHECKREQS_DISK_BUILD="4G"

	check-reqs_pkg_setup
}

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}/${TOR_COMMIT}" "${WORKDIR}/${P}" || die
}

src_prepare() {
	# Apply gentoo firefox patches
	rm "${WORKDIR}/firefox/2005_ffmpeg4.patch"
	eapply "${WORKDIR}/firefox"

	eapply "${FILESDIR}"/bug_1461221.patch
	eapply "${FILESDIR}"/firefox-60.0-blessings-TERM.patch # 654316
	eapply "${FILESDIR}"/firefox-60.0-rust-1.29-comp.patch
	eapply "${FILESDIR}"/firefox-60.0-missing-errno_h-in-SandboxOpenedFiles_cpp.patch

	# Revert "Change the default Firefox profile directory to be TBB-relative"
	eapply "${FILESDIR}/${PN}-60.2.0-Change_the_default_Firefox_profile_directory.patch"

	# FIXME: https://trac.torproject.org/projects/tor/ticket/10925
	# Except lightspark-plugin and freshplayer-plugin from blocklist
	eapply "${FILESDIR}/${PN}-60.2.0-allow-lightspark-and-freshplayerplugin.patch"

	# FIXME: prevent warnings in bundled nss
	eapply "${FILESDIR}/${PN}-60.2.0-nss-fixup-warnings.patch"

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

	# Allow user to apply any additional patches without modifing ebuild
	eapply_user

	# Autotools configure is now called old-configure.in
	# This works because there is still a configure.in that happens to be for the
	# shell wrapper configure script
	eautoreconf old-configure.in

	# Must run autoconf in js/src
	cd "${S}"/js/src || die
	eautoconf old-configure.in
}

src_configure() {
	MEXTENSIONS="default"

	mozconfig_init
	mozconfig_config

	# Add full relro support for hardened
	if use hardened; then
		append-ldflags "-Wl,-z,relro,-z,now"
		mozconfig_use_enable hardened hardening
	fi

	# Disable built-in ccache support to avoid sandbox violation, #665420
	# Use FEATURES=ccache instead!
	mozconfig_annotate '' --without-ccache
	sed -i -e 's/ccache_stats = None/return None/' \
		python/mozbuild/mozbuild/controller/building.py || \
		die "Failed to disable ccache stats call"

	mozconfig_annotate '' --enable-extensions="${MEXTENSIONS}"

	if use clang ; then
		# https://bugzilla.mozilla.org/show_bug.cgi?id=1423822
		mozconfig_annotate 'elf-hack is broken when using Clang' --disable-elf-hack
	fi

	# Use .mozconfig settings from torbrowser (setting this here since it gets overwritten by mozcoreconf-v6.eclass)
	# see https://gitweb.torproject.org/tor-browser.git/tree/.mozconfig?h=tor-browser-60.2.0esr-8.0-1
	echo "mk_add_options MOZ_APP_DISPLAYNAME=\"Tor Browser\"" >> "${S}"/.mozconfig
	echo "mk_add_options MOZILLA_OFFICIAL=1" >> "${S}"/.mozconfig
	echo "mk_add_options BUILD_OFFICIAL=1" >> "${S}"/.mozconfig
	mozconfig_annotate 'torbrowser' --enable-official-branding
	mozconfig_annotate 'torbrowser' --disable-webrtc
	mozconfig_annotate 'torbrowser' --disable-eme
	mozconfig_annotate 'torbrowser' --enable-proxy-bypass-protection

	# rename the binary and set the profile location
	mozconfig_annotate 'torbrowser' --with-app-name=torbrowser
	mozconfig_annotate 'torbrowser' --with-app-basename=torbrowser

	# see https://gitweb.torproject.org/tor-browser.git/tree/old-configure.in?h=tor-browser-60.2.0esr-8.0-1#n3205
	mozconfig_annotate 'torbrowser' --with-tor-browser-version=${TOR_PV}
	mozconfig_annotate 'torbrowser' --disable-tor-browser-update

	# torbrowser uses a patched nss library
	# see https://gitweb.torproject.org/tor-browser.git/log/security/nss?h=tor-browser-60.2.0esr-8.0-1-build1
	mozconfig_annotate 'torbrowser' --without-system-nspr
	mozconfig_annotate 'torbrowser' --without-system-nss

	echo "mk_add_options MOZ_OBJDIR=${BUILD_OBJ_DIR}" >> "${S}"/.mozconfig
	echo "mk_add_options XARGS=/usr/bin/xargs" >> "${S}"/.mozconfig

	# Default mozilla_five_home no longer valid option
	sed '/with-default-mozilla-five-home=/d' -i "${S}"/.mozconfig

	# Finalize and report settings
	mozconfig_final

	# workaround for funky/broken upstream configure...
	SHELL="${SHELL:-${EPREFIX}/bin/bash}" MOZ_NOSPAM=1 \
	./mach configure || die
}

src_compile() {
	MOZ_MAKE_FLAGS="${MAKEOPTS}" SHELL="${SHELL:-${EPREFIX}/bin/bash}" MOZ_NOSPAM=1 \
	./mach build --verbose || die
}

src_install() {
	cd "${BUILD_OBJ_DIR}" || die

	# Pax mark xpcshell for hardened support, only used for startupcache creation.
	pax-mark m "${BUILD_OBJ_DIR}"/dist/bin/xpcshell

	# Add an emty default prefs for the mozconfig eclass:
	touch "${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" \
		|| die

	mozconfig_install_prefs \
		"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js"

	# see: https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-browser/build?h=maint-8.0#n147
	echo "pref(\"extensions.torlauncher.prompt_for_locale\", \"false\");" \
		>> "${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/000-tor-browser.js" \
		|| die
	# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-browser/build?h=maint-8.0#n186
	echo "pref(\"intl.locale.requested\", \"en-US\");" \
		>> "${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/000-tor-browser.js" \
		|| die

	# Reenable defaults/profile functionality
	# see: https://bugzilla.mozilla.org/show_bug.cgi?id=1234012
	# see: https://mike.kaply.com/2016/05/24/default-profile-directory-doesnt-work-in-firefox-46/
	echo "pref(\"general.config.filename\", \"profile.cfg\");" \
		>> "${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/000-tor-browser.js" \
		|| die

	echo "pref(\"general.config.obscure_value\", 0);" \
		>> "${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/000-tor-browser.js" \
		|| die

	insinto ${MOZILLA_FIVE_HOME}
	doins "${FILESDIR}/profile.cfg"

	MOZ_MAKE_FLAGS="${MAKEOPTS}" SHELL="${SHELL:-${EPREFIX%/}/bin/bash}" \
	emake DESTDIR="${D}" install

	# Install icons, wrapper and desktop file
	local size sizes icon_path
	sizes="16 24 32 48 64 128 256"
	icon_path="${S}/browser/branding/official"
	for size in ${sizes}; do
		newicon -s ${size} "${icon_path}/default${size}.png" ${PN}.png
	done

	# see: https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-browser/RelativeLink/start-tor-browser?h=maint-8.0
	# see: https://github.com/Whonix/anon-ws-disable-stacked-tor/blob/master/usr/lib/anon-ws-disable-stacked-tor/torbrowser.sh
	rm "${ED%/}"/usr/bin/torbrowser || die # symlink to /usr/lib64/torbrowser/torbrowser
	newbin - torbrowser <<-EOF
		#!/bin/sh

		unset SESSION_MANAGER

		export TOR_HIDE_UPDATE_CHECK_UI=1
		export TOR_NO_DISPLAY_NETWORK_SETTINGS=1
		export TOR_SKIP_LAUNCH=1
		export TOR_SKIP_CONTROLPORTTEST=1

		exec /usr/$(get_libdir)/torbrowser/torbrowser --class "Tor Browser" "\${@}"
	EOF
	# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-browser/RelativeLink/start-tor-browser.desktop?h=maint-8.0#n25
	make_desktop_entry "${PN}" "Tor Browser" "${PN}" "Network;WebBrowser;Security" "StartupWMClass=Tor Browser"

	# Add StartupNotify=true bug 237317
	if use startup-notification ; then
		echo "StartupNotify=true" \
			>> "${ED}/usr/share/applications/${PN}-${PN}.desktop" \
			|| die
	fi

	# Don't install llvm-symbolizer from sys-devel/llvm package
	[[ -f "${ED%/}${MOZILLA_FIVE_HOME}/llvm-symbolizer" ]] && \
		rm "${ED%/}${MOZILLA_FIVE_HOME}/llvm-symbolizer"

	# torbrowser and torbrowser-bin are identical
	rm "${ED%/}"${MOZILLA_FIVE_HOME}/torbrowser-bin || die
	dosym torbrowser ${MOZILLA_FIVE_HOME}/torbrowser-bin

	# Required in order to use plugins and even run torbrowser on hardened.
	pax-mark m "${ED}"${MOZILLA_FIVE_HOME}/{torbrowser,torbrowser-bin,plugin-container}

	# Profile with settings and extensions
	insinto ${MOZILLA_FIVE_HOME}/defaults/profile
	doins -r "${WORKDIR}"/tor-browser_en-US/Browser/TorBrowser/Data/Browser/profile.default/{extensions,bookmarks.html}

	# see: https://trac.torproject.org/projects/tor/ticket/11751#comment:2
	# see: https://github.com/Whonix/anon-ws-disable-stacked-tor/blob/master/usr/lib/anon-ws-disable-stacked-tor/torbrowser.sh
	dodoc "${FILESDIR}/99torbrowser.example"

	dodoc "${WORKDIR}/tor-browser_en-US/Browser/TorBrowser/Docs/ChangeLog.txt"
}

pkg_preinst() {
	gnome2_icon_savelist

	# if the apulse libs are available in MOZILLA_FIVE_HOME then apulse
	# doesn't need to be forced into the LD_LIBRARY_PATH
	if use pulseaudio && has_version ">=media-sound/apulse-0.1.9" ; then
		einfo "APULSE found - Generating library symlinks for sound support"
		local lib
		pushd "${ED}"${MOZILLA_FIVE_HOME} &>/dev/null || die
		for lib in ../apulse/libpulse{.so{,.0},-simple.so{,.0}} ; do
			# a quickpkg rolled by hand will grab symlinks as part of the package,
			# so we need to avoid creating them if they already exist.
			if ! [ -L ${lib##*/} ]; then
				ln -s "${lib}" ${lib##*/} || die
			fi
		done
		popd &>/dev/null || die
	fi
}

pkg_postinst() {
	gnome2_icon_cache_update

	if use pulseaudio && has_version ">=media-sound/apulse-0.1.9"; then
		elog "Apulse was detected at merge time on this system and so it will always be"
		elog "used for sound.  If you wish to use pulseaudio instead please unmerge"
		elog "media-sound/apulse."
	fi

	if [[ -z ${REPLACING_VERSIONS} ]]; then
		ewarn "This patched firefox build is _NOT_ recommended by Tor upstream but uses"
		ewarn "the exact same sources. Use this only if you know what you are doing!"
		elog "Torbrowser uses port 9150 to connect to Tor. You can change the port"
		elog "in /etc/env.d/99torbrowser to match your setup."
		elog "An example file is available at /usr/share/doc/${P}/99torbrowser.example.bz2"
		elog ""
		elog "To get the advanced functionality of Torbutton (network information,"
		elog "new identity), Torbrowser needs to access a control port."
		elog "Set the Variables in /etc/env.d/99torbrowser accordingly."
	fi

	if [[ "${REPLACING_VERSIONS}" ]] && [[ "${REPLACING_VERSIONS}" < "60.2.0_p800" ]]; then
		ewarn "Since this is a major upgrade, you need to start with a fresh profile."
		ewarn "Either move or remove your profile in \"~/.mozilla/torbrowser/\""
		ewarn "and let Torbrowser generate a new one."
	fi
}

pkg_postrm() {
	gnome2_icon_cache_update
}
