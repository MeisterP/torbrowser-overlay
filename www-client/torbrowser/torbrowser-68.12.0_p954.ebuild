# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
WANT_AUTOCONF="2.1"

PYTHON_COMPAT=( python3_{6,7,8,9} )
PYTHON_REQ_USE='ncurses,sqlite,ssl,threads(+)'

MOZ_PV="${PV/_p*}esr"

# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/firefox/config?h=maint-9.5#n4
# and https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-launcher/config?h=maint-9.5#n2
TOR_PV="9.5.4"
TOR_TAG="9.5-1-build1"
TORLAUNCHER_VERSION="0.2.21.8"

# Patch version
PATCH="firefox-68.0-patches-15"

LLVM_MAX_SLOT=10

inherit check-reqs desktop flag-o-matic toolchain-funcs eutils \
	gnome2-utils llvm mozcoreconf-v6 pax-utils xdg-utils \
	autotools multiprocessing

DESCRIPTION="Private browsing without tracking, surveillance, or censorship"
HOMEPAGE="https://www.torproject.org/
	https://gitweb.torproject.org/tor-browser.git"

KEYWORDS="~amd64 ~x86"

SLOT="0"
# BSD license applies to torproject-related code like the patches
# icons are under CCPL-Attribution-3.0
LICENSE="BSD CC-BY-3.0 MPL-2.0 GPL-2 LGPL-2.1"
IUSE="clang cpu_flags_x86_avx2 dbus hardened pulseaudio startup-notification
	+system-av1 +system-harfbuzz +system-icu +system-jpeg +system-libevent
	+system-sqlite +system-libvpx +system-webp"

PATCH_URIS=( https://dev.gentoo.org/~{anarchy,axs,polynomial-c,whissi}/mozilla/patchsets/${PATCH}.tar.xz )
SRC_URI="${SRC_URI}
	https://dist.torproject.org/torbrowser/${TOR_PV}/src-firefox-tor-browser-${MOZ_PV}-${TOR_TAG}.tar.xz
	https://dist.torproject.org/torbrowser/${TOR_PV}/src-tor-launcher-${TORLAUNCHER_VERSION}.tar.xz
	https://dist.torproject.org/torbrowser/${TOR_PV}/tor-browser-linux64-${TOR_PV}_en-US.tar.xz
	https://archive.torproject.org/tor-package-archive/torbrowser/${TOR_PV}/src-firefox-tor-browser-${MOZ_PV}-${TOR_TAG}.tar.xz
	https://archive.torproject.org/tor-package-archive/torbrowser/${TOR_PV}/src-tor-launcher-${TORLAUNCHER_VERSION}.tar.xz
	https://archive.torproject.org/tor-package-archive/torbrowser/${TOR_PV}/tor-browser-linux64-${TOR_PV}_en-US.tar.xz
	${PATCH_URIS[@]}"

CDEPEND="
	>=dev-libs/nss-3.44.4
	>=dev-libs/nspr-4.21
	dev-libs/atk
	dev-libs/expat
	>=x11-libs/cairo-1.10[X]
	>=x11-libs/gtk+-2.18:2
	>=x11-libs/gtk+-3.4.0:3[X]
	x11-libs/gdk-pixbuf
	>=x11-libs/pango-1.22.0
	>=media-libs/libpng-1.6.35:0=[apng]
	>=media-libs/mesa-10.2:*
	media-libs/fontconfig
	>=media-libs/freetype-2.4.10
	kernel_linux? ( !pulseaudio? ( media-libs/alsa-lib ) )
	virtual/freedesktop-icon-theme
	dbus? (
		>=sys-apps/dbus-0.60
		>=dev-libs/dbus-glib-0.72
	)
	startup-notification? ( >=x11-libs/startup-notification-0.8 )
	>=x11-libs/pixman-0.19.2
	>=dev-libs/glib-2.26:2
	>=sys-libs/zlib-1.2.3
	>=dev-libs/libffi-3.0.10:=
	media-video/ffmpeg
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrender
	x11-libs/libXt
	system-av1? (
		>=media-libs/dav1d-0.3.0:=
		>=media-libs/libaom-1.0.0:=
	)
	system-harfbuzz? (
		>=media-libs/harfbuzz-2.4.0:0=
		>=media-gfx/graphite2-1.3.13
	)
	system-icu? ( >=dev-libs/icu-63.1:= )
	system-jpeg? ( >=media-libs/libjpeg-turbo-1.2.1 )
	system-libevent? ( >=dev-libs/libevent-2.0:0=[threads] )
	system-libvpx? ( =media-libs/libvpx-1.7*:0=[postproc] )
	system-sqlite? ( >=dev-db/sqlite-3.28.0:3[secure-delete] )
	system-webp? ( >=media-libs/libwebp-1.0.2:0= )"

RDEPEND="${CDEPEND}
	pulseaudio? (
		|| (
			media-sound/pulseaudio
			>=media-sound/apulse-0.1.9
		)
	)"

DEPEND="${CDEPEND}
	app-arch/zip
	app-arch/unzip
	>=dev-util/cbindgen-0.8.7
	>=net-libs/nodejs-8.11.0
	>=sys-devel/binutils-2.30
	sys-apps/findutils
	virtual/pkgconfig
	>=virtual/rust-1.34.0
	|| (
		(
			sys-devel/clang:10
			!clang? ( sys-devel/llvm:10 )
			clang? (
				=sys-devel/lld-10*
				sys-devel/llvm:10[gold]
			)
		)
		(
			sys-devel/clang:9
			!clang? ( sys-devel/llvm:9 )
			clang? (
				=sys-devel/lld-9*
				sys-devel/llvm:9[gold]
			)
		)
		(
			sys-devel/clang:8
			!clang? ( sys-devel/llvm:8 )
			clang? (
				=sys-devel/lld-8*
				sys-devel/llvm:8[gold]
			)
		)
	)
	pulseaudio? ( media-sound/pulseaudio )
	amd64? ( >=dev-lang/yasm-1.1 virtual/opengl )
	x86? ( >=dev-lang/yasm-1.1 virtual/opengl )
	!system-av1? (
		amd64? ( >=dev-lang/nasm-2.13 )
		x86? ( >=dev-lang/nasm-2.13 )
	)"

S="${WORKDIR}/firefox-tor-browser-${MOZ_PV}-${TOR_TAG}"

BUILD_OBJ_DIR="${S}/tb"

llvm_check_deps() {
	if ! has_version --host-root "sys-devel/clang:${LLVM_SLOT}" ; then
		ewarn "sys-devel/clang:${LLVM_SLOT} is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
		return 1
	fi

	if use clang ; then
		if ! has_version --host-root "=sys-devel/lld-${LLVM_SLOT}*" ; then
			ewarn "=sys-devel/lld-${LLVM_SLOT}* is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
			return 1
		fi
	fi

	einfo "Will use LLVM slot ${LLVM_SLOT}!" >&2
}

pkg_pretend() {
	# Ensure we have enough disk space to compile
	CHECKREQS_DISK_BUILD="4G"

	check-reqs_pkg_pretend
}

pkg_setup() {
	moz_pkgsetup

	# These should *always* be cleaned up anyway
	unset DBUS_SESSION_BUS_ADDRESS \
		DISPLAY \
		ORBIT_SOCKETDIR \
		SESSION_MANAGER \
		XDG_CACHE_HOME \
		XDG_SESSION_COOKIE \
		XAUTHORITY

	addpredict /proc/self/oom_score_adj

	llvm_pkg_setup
}

src_unpack() {
	for a in ${A} ; do
		case "${a}" in
			"src-firefox-tor-browser-${MOZ_PV}-${TOR_TAG}.tar.xz")
				unpack "${a}"
				;;

			"src-tor-launcher-${TORLAUNCHER_VERSION}.tar.xz")
				local destdir="${S}"/browser/extensions/tor-launcher
				echo ">>> Unpacking ${a} to ${destdir}"
				mkdir "${destdir}" || die
				tar -C "${destdir}" -x -o --strip-components 1 \
					-f "${DISTDIR}/${a}" || die
				;;

			"tor-browser-linux64-${TOR_PV}_en-US.tar.xz")
				local destdir="${WORKDIR}"/profile
				echo ">>> Unpacking ${a} to ${destdir}"
				mkdir "${destdir}" || die
				tar -C "${destdir}" -x -o --strip-components 1 \
					-f "${DISTDIR}/${a}" \
					tor-browser_en-US/Browser/TorBrowser/Docs/ChangeLog.txt \
					tor-browser_en-US/Browser/TorBrowser/Data/Browser/profile.default || die
				;;

			*)
				unpack "${a}"
				;;
		esac
	done
}

src_prepare() {
	# Apply gentoo firefox patches
	rm "${WORKDIR}"/firefox/2016_set_CARGO_PROFILE_RELEASE_LTO.patch
	eapply "${WORKDIR}/firefox"

	# Revert "Change the default Firefox profile directory to be TBB-relative"
	eapply "${FILESDIR}"/${PN}-68.8.0-Do_not_store_data_in_the_app_bundle.patch
	eapply "${FILESDIR}"/${PN}-68.8.0-Change_the_default_Firefox_profile_directory.patch
	eapply "${FILESDIR}"/${PN}-68.1.0-hide_about_tbbupdate.patch

	# Make LTO respect MAKEOPTS
	sed -i \
		-e "s/multiprocessing.cpu_count()/$(makeopts_jobs)/" \
		"${S}"/build/moz.configure/toolchain.configure \
		|| die "sed failed to set num_cores"

	# Allow user to apply any additional patches without modifing ebuild
	eapply_user

	einfo "Removing pre-built binaries ..."
	find "${S}"/third_party -type f \( -name '*.so' -o -name '*.o' \) -print -delete || die

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

	# rustfmt, a tool to format Rust code, is optional and not required to build Firefox.
	# However, when available, an unsupported version can cause problems, bug #669548
	sed -i -e "s@check_prog('RUSTFMT', add_rustup_path('rustfmt')@check_prog('RUSTFMT', add_rustup_path('rustfmt_do_not_use')@" \
		"${S}"/build/moz.configure/rust.configure || die

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

	# Add information about TERM to output (build.log) to aid debugging
	# blessings problems
	if [[ -n "${TERM}" ]] ; then
		einfo "TERM is set to: \"${TERM}\""
	else
		einfo "TERM is unset."
	fi

	if use clang && ! tc-is-clang ; then
		# Force clang
		einfo "Enforcing the use of clang due to USE=clang ..."
		CC=${CHOST}-clang
		CXX=${CHOST}-clang++
		strip-unsupported-flags
	elif ! use clang && ! tc-is-gcc ; then
		# Force gcc
		einfo "Enforcing the use of gcc due to USE=-clang ..."
		CC=${CHOST}-gcc
		CXX=${CHOST}-g++
		strip-unsupported-flags
	fi

	mozconfig_init
	# common config components
	mozconfig_annotate 'system_libs' \
		--with-system-zlib \
		--with-system-bz2

	# Must pass release in order to properly select linker
	mozconfig_annotate 'Enable by Gentoo' --enable-release

	# Don't let user's LTO flags clash with upstream's flags
	filter-flags -flto*

	# Avoid auto-magic on linker
	if use clang ; then
		# This is upstream's default
		mozconfig_annotate "forcing ld=lld due to USE=clang" --enable-linker=lld
	elif tc-ld-is-gold ; then
		mozconfig_annotate "linker is set to gold" --enable-linker=gold
	else
		mozconfig_annotate "linker is set to bfd" --enable-linker=bfd
	fi

	# Add full relro support for hardened
	if use hardened ; then
		append-ldflags "-Wl,-z,relro,-z,now"
		mozconfig_use_enable hardened hardening
	fi

	# These are enabled by default in all mozilla applications
	mozconfig_annotate '' --with-system-nspr --with-nspr-prefix="${SYSROOT}${EPREFIX}"/usr
	mozconfig_annotate '' --with-system-nss --with-nss-prefix="${SYSROOT}${EPREFIX}"/usr
	mozconfig_annotate '' --x-includes="${SYSROOT}${EPREFIX}"/usr/include \
		--x-libraries="${SYSROOT}${EPREFIX}"/usr/$(get_libdir)
	mozconfig_annotate '' --prefix="${EPREFIX}"/usr
	mozconfig_annotate '' --libdir="${EPREFIX}"/usr/$(get_libdir)
	mozconfig_annotate 'Gentoo default' --with-system-png
	mozconfig_annotate '' --enable-system-ffi
	mozconfig_annotate '' --disable-gconf
	mozconfig_annotate '' --with-intl-api
	mozconfig_annotate '' --enable-system-pixman
	mozconfig_annotate '' --target="${CHOST}"
	mozconfig_annotate '' --host="${CBUILD:-${CHOST}}"
	mozconfig_annotate '' --with-toolchain-prefix="${CHOST}-"
	if use system-libevent ; then
		mozconfig_annotate '' --with-system-libevent="${SYSROOT}${EPREFIX}"/usr
	fi

	if ! use x86; then
		mozconfig_annotate '' --enable-rust-simd
	fi

	mozconfig_use_enable startup-notification
	mozconfig_use_enable system-sqlite
	mozconfig_use_with system-av1
	mozconfig_use_with system-harfbuzz
	mozconfig_use_with system-harfbuzz system-graphite2
	mozconfig_use_with system-icu
	mozconfig_use_with system-jpeg
	mozconfig_use_with system-libvpx
	mozconfig_use_with system-webp
	mozconfig_use_enable pulseaudio
	# force the deprecated alsa sound code if pulseaudio is disabled
	if use kernel_linux && ! use pulseaudio ; then
		mozconfig_annotate '-pulseaudio' --enable-alsa
	fi

	# Disable built-in ccache support to avoid sandbox violation, #665420
	# Use FEATURES=ccache instead!
	mozconfig_annotate '' --without-ccache
	sed -i -e 's/ccache_stats = None/return None/' \
		python/mozbuild/mozbuild/controller/building.py || \
		die "Failed to disable ccache stats call"

	mozconfig_use_enable dbus

	mozconfig_annotate '' --disable-necko-wifi

	mozconfig_annotate '' --disable-geckodriver

	mozconfig_annotate '' --enable-extensions="${MEXTENSIONS}"

	# allow elfhack to work in combination with unstripped binaries
	# when they would normally be larger than 2GiB.
	append-ldflags "-Wl,--compress-debug-sections=zlib"

	if use clang ; then
		# https://bugzilla.mozilla.org/show_bug.cgi?id=1482204
		# https://bugzilla.mozilla.org/show_bug.cgi?id=1483822
		mozconfig_annotate 'elf-hack is broken when using Clang' --disable-elf-hack
	fi

	# Rename the binary and set the profile location
	mozconfig_annotate 'torbrowser' --with-app-name=torbrowser
	mozconfig_annotate 'torbrowser' --with-app-basename=torbrowser

	# Use .mozconfig settings from torbrowser (setting this here since it gets overwritten by mozcoreconf-v6.eclass)
	# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/firefox/mozconfig-linux-x86_64?h=maint-9.5
	echo "mk_add_options MOZ_APP_DISPLAYNAME=\"Tor Browser\"" >> "${S}"/.mozconfig
	export MOZILLA_OFFICIAL=1
	mozconfig_annotate 'torbrowser' --enable-optimize
	mozconfig_annotate 'torbrowser' --enable-official-branding
	mozconfig_annotate 'torbrowser' --enable-default-toolkit=cairo-gtk3
	mozconfig_annotate 'torbrowser' --disable-strip
	mozconfig_annotate 'torbrowser' --disable-install-strip
	mozconfig_annotate 'torbrowser' --disable-tests
	mozconfig_annotate 'torbrowser' --disable-debug
	mozconfig_annotate 'torbrowser' --disable-crashreporter
	mozconfig_annotate 'torbrowser' --disable-webrtc
	mozconfig_annotate 'torbrowser' --disable-eme
	mozconfig_annotate 'torbrowser' --enable-proxy-bypass-protection
	mozconfig_annotate 'torbrowser' MOZ_TELEMETRY_REPORTING=

	# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/firefox/build?h=maint-9.5#n123
	# and https://gitweb.torproject.org/tor-browser.git/tree/old-configure.in?h=tor-browser-68.9.0esr-9.5-1#n2193
	mozconfig_annotate 'torbrowser' --with-tor-browser-version=${TOR_PV}
	#mozconfig_annotate 'torbrowser' --with-distribution-id=org.torproject
	mozconfig_annotate 'torbrowser' --enable-update-channel=release
	mozconfig_annotate 'torbrowser' --enable-bundled-fonts
	mozconfig_annotate 'torbrowser' --with-branding=browser/branding/official
	mozconfig_annotate 'torbrowser' --disable-tor-browser-update
	mozconfig_annotate 'torbrowser' --enable-tor-launcher

	echo "mk_add_options MOZ_OBJDIR=${BUILD_OBJ_DIR}" >> "${S}"/.mozconfig
	echo "mk_add_options XARGS=/usr/bin/xargs" >> "${S}"/.mozconfig

	# Finalize and report settings
	mozconfig_final

	mkdir -p "${S}"/third_party/rust/libloading/.deps

	# workaround for funky/broken upstream configure...
	SHELL="${SHELL:-${EPREFIX}/bin/bash}" MOZ_NOSPAM=1 \
	./mach configure || die
}

src_compile() {
	local _virtx=
	GDK_BACKEND=x11 \
		MOZ_MAKE_FLAGS="${MAKEOPTS} -O" \
		SHELL="${SHELL:-${EPREFIX}/bin/bash}" \
		MOZ_NOSPAM=1 \
		${_virtx} \
		./mach build --verbose \
		|| die
}

src_install() {
	local profile_dir="${WORKDIR}/profile/Browser/TorBrowser/Data/Browser/profile.default"
	cd "${BUILD_OBJ_DIR}" || die

	# Default bookmarks
	cat "${profile_dir}"/bookmarks.html > \
		"${BUILD_OBJ_DIR}"/dist/bin/browser/chrome/en-US/locale/browser/bookmarks.html

	# Pax mark xpcshell for hardened support, only used for startupcache creation.
	pax-mark m "${BUILD_OBJ_DIR}"/dist/bin/xpcshell

	# Add an emty default prefs for the mozconfig eclass:
	touch "${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" \
		|| die

	# set dictionary path, to use system hunspell
	echo "pref(\"spellchecker.dictionary_path\", \"${EPREFIX}/usr/share/myspell\");" \
		>>"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" || die

	# force the graphite pref if system-harfbuzz is enabled, since the pref cant disable it
	if use system-harfbuzz ; then
		echo "sticky_pref(\"gfx.font_rendering.graphite.enabled\",true);" \
			>>"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" || die
	fi

	# see: https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-browser/build?h=maint-9.0#n118
	echo "pref(\"extensions.torlauncher.prompt_for_locale\", \"false\");" \
		>> "${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/000-tor-browser.js" \
		|| die
	# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-browser/build?h=maint-9.0#n154
	echo "pref(\"intl.locale.requested\", \"en-US\");" \
		>> "${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/000-tor-browser.js" \
		|| die

	cd "${S}"
	MOZ_MAKE_FLAGS="${MAKEOPTS}" SHELL="${SHELL:-${EPREFIX}/bin/bash}" MOZ_NOSPAM=1 \
	DESTDIR="${D}" ./mach install || die

	# Install icons, wrapper and desktop file
	local size icon_path
	icon_path="${S}/browser/branding/official"
	for size in 16 32 48 64 128 256 512; do
		newicon -s ${size} "${icon_path}/default${size}.png" "${PN}.png"
	done
	newicon "${icon_path}/default48.png" "${PN}.png"

	# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-browser/RelativeLink/start-tor-browser.desktop?h=maint-9.0
	domenu "${FILESDIR}"/torbrowser.desktop

	# Add StartupNotify=true bug 237317
	if use startup-notification ; then
		echo "StartupNotify=true" \
			>> "${ED}/usr/share/applications/${PN}.desktop" \
			|| die
	fi

	# see: https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-browser/RelativeLink/start-tor-browser?h=maint-9.0
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

	# Don't install llvm-symbolizer from sys-devel/llvm package
	[[ -f "${ED%/}${MOZILLA_FIVE_HOME}/llvm-symbolizer" ]] && \
		rm "${ED%/}${MOZILLA_FIVE_HOME}/llvm-symbolizer"

	# torbrowser and torbrowser-bin are identical
	rm "${ED%/}"${MOZILLA_FIVE_HOME}/torbrowser-bin || die
	dosym torbrowser ${MOZILLA_FIVE_HOME}/torbrowser-bin

	# Required in order to use plugins and even run torbrowser on hardened.
	pax-mark m "${ED%/}"${MOZILLA_FIVE_HOME}/{torbrowser,plugin-container}

	# Default Extensions
	insinto ${MOZILLA_FIVE_HOME}/browser
	doins -r "${profile_dir}"/extensions

	# see: https://trac.torproject.org/projects/tor/ticket/11751#comment:2
	# see: https://github.com/Whonix/anon-ws-disable-stacked-tor/blob/master/usr/lib/anon-ws-disable-stacked-tor/torbrowser.sh
	dodoc "${FILESDIR}/99torbrowser.example"

	dodoc "${WORKDIR}/profile/Browser/TorBrowser/Docs/ChangeLog.txt"
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
			if [[ ! -L ${lib##*/} ]] ; then
				ln -s "${lib}" ${lib##*/} || die
			fi
		done
		popd &>/dev/null || die
	fi
}

pkg_postinst() {
	gnome2_icon_cache_update
	xdg_desktop_database_update

	if use pulseaudio && has_version ">=media-sound/apulse-0.1.9"; then
		elog "Apulse was detected at merge time on this system and so it will always be"
		elog "used for sound.  If you wish to use pulseaudio instead please unmerge"
		elog "media-sound/apulse."
		elog
	fi

	if [[ -z ${REPLACING_VERSIONS} ]]; then
		ewarn "This patched firefox build is _NOT_ recommended by Tor upstream but uses"
		ewarn "the exact same sources. Use this only if you know what you are doing!"
		elog "Torbrowser uses port 9150 to connect to Tor. You can change the port"
		elog "in /etc/env.d/99torbrowser to match your setup."
		elog "An example file is available at /usr/share/doc/${P}/99torbrowser.example.bz2"
		elog ""
		elog "To get the advanced functionality (network information,"
		elog "new identity), Torbrowser needs to access a control port."
		elog "Set the Variables in /etc/env.d/99torbrowser accordingly."
	fi
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}
