# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

FIREFOX_PATCHSET="firefox-78esr-patches-07.tar.xz"

LLVM_MAX_SLOT=11

PYTHON_COMPAT=( python3_{7..9} )
PYTHON_REQ_USE="ncurses,sqlite,ssl"

WANT_AUTOCONF="2.1"

# Convert the ebuild version to the upstream mozilla version, used by mozlinguas
MOZ_PV="${PV/_p*}esr"

# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/firefox/config?h=maint-10.0-desktop#n4
# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/firefox/config?h=maint-10.0-desktop#n11
# and https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-launcher/config?h=maint-10.0-desktop#n2
# and https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/https-everywhere/config?h=maint-10.0-desktop#n2
# and https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-browser/config?h=maint-10.0-desktop#n80
TOR_PV="10.0.9"
TOR_TAG="10.0-2-build1"
TORLAUNCHER_VERSION="0.2.26"
HTTPSEVERYWHERE_VERSION="2020.11.17"
NOSCRIPT_VERSION="11.1.9"

inherit autotools check-reqs desktop flag-o-matic gnome2-utils llvm \
	multiprocessing pax-utils python-any-r1 toolchain-funcs \
	xdg eutils

TOR_SRC_BASE_URI="https://dist.torproject.org/torbrowser/${TOR_PV}"
TOR_SRC_ARCHIVE_URI="https://archive.torproject.org/tor-package-archive/torbrowser/${TOR_PV}"

PATCH_URIS=(
	https://dev.gentoo.org/~{axs,polynomial-c,whissi}/mozilla/patchsets/${FIREFOX_PATCHSET}
)

SRC_URI="
	${TOR_SRC_BASE_URI}/src-firefox-tor-browser-${MOZ_PV}-${TOR_TAG}.tar.xz
	${TOR_SRC_BASE_URI}/src-tor-launcher-${TORLAUNCHER_VERSION}.tar.xz
	${TOR_SRC_BASE_URI}/tor-browser-linux64-${TOR_PV}_en-US.tar.xz
	${TOR_SRC_ARCHIVE_URI}/src-firefox-tor-browser-${MOZ_PV}-${TOR_TAG}.tar.xz
	${TOR_SRC_ARCHIVE_URI}/src-tor-launcher-${TORLAUNCHER_VERSION}.tar.xz
	${TOR_SRC_ARCHIVE_URI}/tor-browser-linux64-${TOR_PV}_en-US.tar.xz
	https://addons.cdn.mozilla.net/user-media/addons/722/noscript_security_suite-${NOSCRIPT_VERSION}-an+fx.xpi
	https://www.eff.org/files/https-everywhere-${HTTPSEVERYWHERE_VERSION}-eff.xpi
	${PATCH_URIS[@]}"

DESCRIPTION="Private browsing without tracking, surveillance, or censorship"
HOMEPAGE="https://www.torproject.org/ https://gitweb.torproject.org/tor-browser.git"

KEYWORDS="~amd64 ~x86"

SLOT="0"
LICENSE="BSD CC-BY-3.0 MPL-2.0 GPL-2 LGPL-2.1"
IUSE="+clang dbus
	hardened pulseaudio
	+system-av1 +system-harfbuzz +system-icu +system-jpeg +system-libevent
	+system-libvpx +system-webp"

BDEPEND="${PYTHON_DEPS}
	app-arch/unzip
	app-arch/zip
	>=dev-util/cbindgen-0.14.3
	>=net-libs/nodejs-10.21.1
	virtual/pkgconfig
	>=virtual/rust-1.41.0
	|| (
		(
			sys-devel/clang:11
			sys-devel/llvm:11
			clang? (
				=sys-devel/lld-11*
			)
		)
		(
			sys-devel/clang:10
			sys-devel/llvm:10
			clang? (
				=sys-devel/lld-10*
			)
		)
		(
			sys-devel/clang:9
			sys-devel/llvm:9
			clang? (
				=sys-devel/lld-9*
			)
		)
	)
	>=dev-lang/yasm-1.1
	!system-av1? (
		>=dev-lang/nasm-2.13
	)"

CDEPEND="
	>=dev-libs/nss-3.53.1
	>=dev-libs/nspr-4.25
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
	dbus? (
		sys-apps/dbus
		dev-libs/dbus-glib
	)
	system-av1? (
		>=media-libs/dav1d-0.3.0:=
		>=media-libs/libaom-1.0.0:=
	)
	system-harfbuzz? (
		>=media-libs/harfbuzz-2.6.8:0=
		>=media-gfx/graphite2-1.3.13
	)
	system-icu? ( >=dev-libs/icu-67.1:= )
	system-jpeg? ( >=media-libs/libjpeg-turbo-1.2.1 )
	system-libevent? ( >=dev-libs/libevent-2.0:0=[threads] )
	system-libvpx? ( >=media-libs/libvpx-1.8.2:0=[postproc] )
	system-webp? ( >=media-libs/libwebp-1.1.0:0= )"

RDEPEND="${CDEPEND}
	pulseaudio? (
		|| (
			media-sound/pulseaudio
			>=media-sound/apulse-0.1.12-r4
		)
	)"

DEPEND="${CDEPEND}
	pulseaudio? (
		|| (
			media-sound/pulseaudio
			>=media-sound/apulse-0.1.12-r4[sdk]
		)
	)
	virtual/opengl"

S="${WORKDIR}/firefox-tor-browser-${MOZ_PV}-${TOR_TAG}"

moz_clear_vendor_checksums() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -ne 1 ]] ; then
		die "${FUNCNAME} requires exact one argument"
	fi

	einfo "Clearing cargo checksums for ${1} ..."

	sed -i \
		-e 's/\("files":{\)[^}]*/\1/' \
		"${S}"/third_party/rust/${1}/.cargo-checksum.json \
		|| die
}

mozconfig_add_options_ac() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -lt 2 ]] ; then
		die "${FUNCNAME} requires at least two arguments"
	fi

	local reason=${1}
	shift

	local option
	for option in "${@}" ; do
		echo "ac_add_options ${option} # ${reason}" >>${MOZCONFIG}
	done
}

mozconfig_add_options_mk() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -lt 2 ]] ; then
		die "${FUNCNAME} requires at least two arguments"
	fi

	local reason=${1}
	shift

	local option
	for option in "${@}" ; do
		echo "mk_add_options ${option} # ${reason}" >>${MOZCONFIG}
	done
}

mozconfig_use_enable() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -lt 1 ]] ; then
		die "${FUNCNAME} requires at least one arguments"
	fi

	local flag=$(use_enable "${@}")
	mozconfig_add_options_ac "$(use ${1} && echo +${1} || echo -${1})" "${flag}"
}

mozconfig_use_with() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -lt 1 ]] ; then
		die "${FUNCNAME} requires at least one arguments"
	fi

	local flag=$(use_with "${@}")
	mozconfig_add_options_ac "$(use ${1} && echo +${1} || echo -${1})" "${flag}"
}

pkg_pretend() {
	# Ensure we have enough disk space to compile
	CHECKREQS_DISK_BUILD="6400M"

	check-reqs_pkg_pretend
}

pkg_setup() {
	# Ensure we have enough disk space to compile
	CHECKREQS_DISK_BUILD="5G"

	check-reqs_pkg_setup

	llvm_pkg_setup

	python-any-r1_pkg_setup

	# These should *always* be cleaned up anyway
	unset \
		DBUS_SESSION_BUS_ADDRESS \
		DISPLAY \
		ORBIT_SOCKETDIR \
		SESSION_MANAGER \
		XAUTHORITY \
		XDG_CACHE_HOME \
		XDG_SESSION_COOKIE

	# Build system is using /proc/self/oom_score_adj, bug #604394
	addpredict /proc/self/oom_score_adj

	if ! mountpoint -q /dev/shm ; then
		# If /dev/shm is not available, configure is known to fail with
		# a traceback report referencing /usr/lib/pythonN.N/multiprocessing/synchronize.py
		ewarn "/dev/shm is not mounted -- expect build failures!"
	fi

	# Ensure we use C locale when building, bug #746215
	export LC_ALL=C
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

	# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-browser/build?h=maint-10.0#n81
			"https-everywhere-${HTTPSEVERYWHERE_VERSION}-eff.xpi")
				local destdir="${WORKDIR}"/https-everywhere/chrome/torbutton/content/extensions/https-everywhere/
				echo ">>> Unpacking ${a} to ${destdir}"
				mkdir -p "${destdir}" || die
				unzip -qo "${DISTDIR}/${a}" -d "${destdir}" || die
				;;

			"noscript_security_suite-${NOSCRIPT_VERSION}-an+fx.xpi")
				local destdir="${WORKDIR}"
				echo ">>> Copying ${a} to ${destdir}"
				cp "${DISTDIR}/${a}" "${destdir}" || die
				;;

	# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-browser/build?h=maint-10.0#n35
			"tor-browser-linux64-${TOR_PV}_en-US.tar.xz")
				local destdir="${WORKDIR}"/profile
				echo ">>> Unpacking ${a} to ${destdir}"
				mkdir "${destdir}" || die
				tar -C "${destdir}" -x -o --strip-components 1 \
					-f "${DISTDIR}/${a}" \
					tor-browser_en-US/Browser/TorBrowser/Docs \
					tor-browser_en-US/Browser/TorBrowser/Data/Browser/profile.default || die
				;;

			*)
				unpack "${a}"
				;;
		esac
	done
}

src_prepare() {
	eapply "${WORKDIR}/firefox-patches"

	# Revert "Change the default Firefox profile directory to be TBB-relative"
	eapply "${FILESDIR}"/${PN}-78.2.0-Do_not_store_data_in_the_app_bundle.patch
	eapply "${FILESDIR}"/${PN}-78.2.0-Change_the_default_Firefox_profile_directory.patch
	eapply "${FILESDIR}"/${PN}-68.1.0-hide_about_tbbupdate.patch

	# Allow user to apply any additional patches without modifing ebuild
	eapply_user

	# Make LTO respect MAKEOPTS
	sed -i \
		-e "s/multiprocessing.cpu_count()/$(makeopts_jobs)/" \
		"${S}"/build/moz.configure/lto-pgo.configure \
		|| die "sed failed to set num_cores"

	# Make ICU respect MAKEOPTS
	sed -i \
		-e "s/multiprocessing.cpu_count()/$(makeopts_jobs)/" \
		"${S}"/intl/icu_sources_data.py \
		|| die "sed failed to set num_cores"

	# sed-in toolchain prefix
	sed -i \
		-e "s/objdump/${CHOST}-objdump/" \
		"${S}"/python/mozbuild/mozbuild/configure/check_debug_ranges.py \
		|| die "sed failed to set toolchain prefix"

	sed -i \
		-e 's/ccache_stats = None/return None/' \
		"${S}"/python/mozbuild/mozbuild/controller/building.py \
		|| die "sed failed to disable ccache stats call"

	einfo "Removing pre-built binaries ..."
	find "${S}"/third_party -type f \( -name '*.so' -o -name '*.o' \) -print -delete || die

	# Clearing checksums where we have applied patches
	moz_clear_vendor_checksums target-lexicon-0.9.0

	# Create build dir
	BUILD_DIR="${WORKDIR}/${PN}_build"
	mkdir -p "${BUILD_DIR}" || die

	xdg_src_prepare
}

src_configure() {
	# Show flags set at the beginning
	einfo "Current CFLAGS:    ${CFLAGS}"
	einfo "Current LDFLAGS:   ${LDFLAGS}"
	einfo "Current RUSTFLAGS: ${RUSTFLAGS}"

	local have_switched_compiler=
	if use clang && ! tc-is-clang ; then
		# Force clang
		einfo "Enforcing the use of clang due to USE=clang ..."
		have_switched_compiler=yes
		AR=llvm-ar
		CC=${CHOST}-clang
		CXX=${CHOST}-clang++
		NM=llvm-nm
		RANLIB=llvm-ranlib
	elif ! use clang && ! tc-is-gcc ; then
		# Force gcc
		have_switched_compiler=yes
		einfo "Enforcing the use of gcc due to USE=-clang ..."
		AR=gcc-ar
		CC=${CHOST}-gcc
		CXX=${CHOST}-g++
		NM=gcc-nm
		RANLIB=gcc-ranlib
	fi

	if [[ -n "${have_switched_compiler}" ]] ; then
		# Because we switched active compiler we have to ensure
		# that no unsupported flags are set
		strip-unsupported-flags
	fi

	# Ensure we use correct toolchain
	export HOST_CC="$(tc-getBUILD_CC)"
	export HOST_CXX="$(tc-getBUILD_CXX)"
	tc-export CC CXX LD AR NM OBJDUMP RANLIB PKG_CONFIG

	# Set MOZILLA_FIVE_HOME
	export MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"

	# python/mach/mach/mixin/process.py fails to detect SHELL
	export SHELL="${EPREFIX}/bin/bash"

	# Set MOZCONFIG
	export MOZCONFIG="${S}/.mozconfig"

	# Initialize MOZCONFIG
	mozconfig_add_options_ac '' --enable-application=browser

	# Avoid auto-magic on linker
	if use clang ; then
		# This is upstream's default
		mozconfig_add_options_ac "forcing ld=lld due to USE=clang" --enable-linker=lld
	elif tc-ld-is-gold ; then
		mozconfig_add_options_ac "linker is set to gold" --enable-linker=gold
	else
		mozconfig_add_options_ac "linker is set to bfd" --enable-linker=bfd
	fi

	# LTO flag was handled via configure
	filter-flags '-flto*'

	if is-flag '-g*' ; then
		if use clang ; then
			mozconfig_add_options_ac 'from CFLAGS' --enable-debug-symbols=$(get-flag '-g*')
		else
			mozconfig_add_options_ac 'from CFLAGS' --enable-debug-symbols
		fi
	else
		mozconfig_add_options_ac 'Gentoo default' --disable-debug-symbols
	fi

	if is-flag '-O0' ; then
		mozconfig_add_options_ac "from CFLAGS" --enable-optimize=-O0
	elif is-flag '-O4' ; then
		mozconfig_add_options_ac "from CFLAGS" --enable-optimize=-O4
	elif is-flag '-O3' ; then
		mozconfig_add_options_ac "from CFLAGS" --enable-optimize=-O3
	elif is-flag '-O1' ; then
		mozconfig_add_options_ac "from CFLAGS" --enable-optimize=-O1
	elif is-flag '-Os' ; then
		mozconfig_add_options_ac "from CFLAGS" --enable-optimize=-Os
	else
		mozconfig_add_options_ac "Gentoo default" --enable-optimize=-O2
	fi

	# Debug flag was handled via configure
	filter-flags '-g*'

	# Optimization flag was handled via configure
	filter-flags '-O*'

	mozconfig_add_options_ac 'Gentoo default' \
		--allow-addon-sideload \
		--disable-cargo-incremental \
		--disable-crashreporter \
		--disable-install-strip \
		--disable-strip \
		--disable-updater \
		--enable-official-branding \
		--enable-release \
		--enable-system-ffi \
		--enable-system-pixman \
		--host="${CBUILD:-${CHOST}}" \
		--libdir="${EPREFIX}/usr/$(get_libdir)" \
		--prefix="${EPREFIX}/usr" \
		--target="${CHOST}" \
		--without-ccache \
		--with-intl-api \
		--with-libclang-path="$(llvm-config --libdir)" \
		--with-system-nspr \
		--with-system-nss \
		--with-system-png \
		--with-system-zlib \
		--with-toolchain-prefix="${CHOST}-" \
		--with-unsigned-addon-scopes=app,system \
		--x-includes="${SYSROOT}${EPREFIX}/usr/include" \
		--x-libraries="${SYSROOT}${EPREFIX}/usr/$(get_libdir)"

	if ! use x86 ; then
		mozconfig_add_options_ac '' --enable-rust-simd
	fi

	mozconfig_use_with system-av1
	mozconfig_use_with system-harfbuzz
	mozconfig_use_with system-harfbuzz system-graphite2
	mozconfig_use_with system-icu
	mozconfig_use_with system-jpeg
	mozconfig_use_with system-libevent system-libevent "${SYSROOT}${EPREFIX}/usr"
	mozconfig_use_with system-libvpx
	mozconfig_use_with system-webp

	mozconfig_use_enable dbus

	mozconfig_add_options_ac '' --disable-eme

	mozconfig_add_options_ac '' --disable-geckodriver

	if use hardened ; then
		mozconfig_add_options_ac "+hardened" --enable-hardening
		append-ldflags "-Wl,-z,relro -Wl,-z,now"
	fi

	mozconfig_add_options_ac '' --disable-jack

	mozconfig_use_enable pulseaudio
	# force the deprecated alsa sound code if pulseaudio is disabled
	if use kernel_linux && ! use pulseaudio ; then
		mozconfig_add_options_ac '-pulseaudio' --enable-alsa
	fi

	mozconfig_add_options_ac '' --disable-pipewire

	mozconfig_add_options_ac '' --disable-necko-wifi

	mozconfig_add_options_ac '' --enable-default-toolkit=cairo-gtk3

	# Rename the binary and set the profile location
	mozconfig_add_options_ac 'torbrowser' --with-app-name=torbrowser
	mozconfig_add_options_ac 'torbrowser' --with-app-basename=torbrowser

	# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/firefox/mozconfig-linux-x86_64
	mozconfig_add_options_mk 'torbrowser' "MOZ_APP_DISPLAYNAME=\"Tor Browser\""
	export MOZILLA_OFFICIAL=1

	# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/firefox/build#n135
	# and https://gitweb.torproject.org/tor-browser.git/tree/old-configure.in?h=tor-browser-78.2.0esr-10.0-1#n1969
	mozconfig_add_options_ac 'torbrowser' \
		--enable-optimize \
		--enable-official-branding \
		--enable-default-toolkit=cairo-gtk3 \
		--disable-strip \
		--disable-install-strip \
		--disable-tests \
		--disable-debug \
		--disable-crashreporter \
		--disable-webrtc \
		--disable-parental-controls \
		--disable-eme \
		--enable-proxy-bypass-protection \
		MOZ_TELEMETRY_REPORTING= \
		--with-tor-browser-version=${TOR_PV}  \
		--enable-update-channel=release \
		--enable-bundled-fonts \
		--with-branding=browser/branding/official \
		--disable-tor-browser-update \
		--enable-tor-launcher

	if use clang ; then
		# https://bugzilla.mozilla.org/show_bug.cgi?id=1482204
		# https://bugzilla.mozilla.org/show_bug.cgi?id=1483822
		# toolkit/moz.configure Elfhack section: target.cpu in ('arm', 'x86', 'x86_64')
		local disable_elf_hack=
		if use amd64 ; then
			disable_elf_hack=yes
		elif use x86 ; then
			disable_elf_hack=yes
		elif use arm ; then
			disable_elf_hack=yes
		fi

		if [[ -n ${disable_elf_hack} ]] ; then
			mozconfig_add_options_ac 'elf-hack is broken when using Clang' --disable-elf-hack
		fi
	fi

	# Allow elfhack to work in combination with unstripped binaries
	# when they would normally be larger than 2GiB.
	append-ldflags "-Wl,--compress-debug-sections=zlib"

	# Pass $MAKEOPTS to build system
	export MOZ_MAKE_FLAGS="${MAKEOPTS}"

	# Use system's Python environment
	export MACH_USE_SYSTEM_PYTHON=1

	# Disable notification when build system has finished
	export MOZ_NOSPAM=1

	# Build system requires xargs but is unable to find it
	mozconfig_add_options_mk 'Gentoo default' "XARGS=${EPREFIX}/usr/bin/xargs"

	# Set build dir
	mozconfig_add_options_mk 'Gentoo default' "MOZ_OBJDIR=${BUILD_DIR}"

	# Handle EXTRA_CONF and show summary
	local ac opt hash reason

	# Apply EXTRA_ECONF entries to $MOZCONFIG
	if [[ -n ${EXTRA_ECONF} ]] ; then
		IFS=\! read -a ac <<<${EXTRA_ECONF// --/\!}
		for opt in "${ac[@]}"; do
			mozconfig_add_options_ac "EXTRA_ECONF" --${opt#--}
		done
	fi

	echo
	echo "=========================================================="
	echo "Building ${PF} with the following configuration"
	grep ^ac_add_options "${MOZCONFIG}" | while read ac opt hash reason; do
		[[ -z ${hash} || ${hash} == \# ]] \
			|| die "error reading mozconfig: ${ac} ${opt} ${hash} ${reason}"
		printf "    %-30s  %s\n" "${opt}" "${reason:-mozilla.org default}"
	done
	echo "=========================================================="
	echo

	./mach configure || die
}

src_compile() {
	local -x GDK_BACKEND=x11

	./mach build --verbose || die
}

src_install() {
	# Default bookmarks
	local PROFILE_DIR="${WORKDIR}/profile/Browser/TorBrowser/Data/Browser/profile.default"
	cat "${PROFILE_DIR}"/bookmarks.html > \
		"${WORKDIR}"/torbrowser_build/dist/bin/browser/chrome/en-US/locale/browser/bookmarks.html || die

	# xpcshell is getting called during install
	pax-mark m \
		"${BUILD_DIR}"/dist/bin/xpcshell \
		"${BUILD_DIR}"/dist/bin/torbrowser \
		"${BUILD_DIR}"/dist/bin/plugin-container

	DESTDIR="${D}" ./mach install || die

	# Upstream cannot ship symlink but we can (bmo#658850)
	rm "${ED}${MOZILLA_FIVE_HOME}/${PN}-bin" || die
	dosym ${PN} ${MOZILLA_FIVE_HOME}/${PN}-bin

	# Don't install llvm-symbolizer from sys-devel/llvm package
	if [[ -f "${ED}${MOZILLA_FIVE_HOME}/llvm-symbolizer" ]] ; then
		rm -v "${ED}${MOZILLA_FIVE_HOME}/llvm-symbolizer" || die
	fi

	# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-browser/build?h=maint-10.0#n48
	insinto ${MOZILLA_FIVE_HOME}/browser/extensions
	newins "${WORKDIR}"/noscript_security_suite-${NOSCRIPT_VERSION}-an+fx.xpi {73a6fe31-595d-460b-a920-fcc0f8843232}.xpi

	# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-browser/build?h=maint-10.0#n84
	pushd "${WORKDIR}"/https-everywhere || die
		find chrome/ | zip -q -X -@ "${ED}${MOZILLA_FIVE_HOME}/omni.ja"
	popd || die

	local PREFS_DIR="${MOZILLA_FIVE_HOME}/browser/defaults/preferences"
	insinto "${PREFS_DIR}"

	# see: https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-browser/build#n134
	# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-browser/build#n170
	newins - 000-tor-browser.js <<-EOF
		pref("extensions.torlauncher.prompt_for_locale", "false");
		pref("intl.locale.requested", "en-US");
	EOF

	# Set dictionary path to use system hunspell
	newins - all-gentoo.js <<-EOF
		pref("spellchecker.dictionary_path", "${EPREFIX}/usr/share/myspell");
	EOF

	local GENTOO_PREFS="${ED}${PREFS_DIR}/all-gentoo.js"

	# Force the graphite pref if USE=system-harfbuzz is enabled, since the pref cannot disable it
	if use system-harfbuzz ; then
		cat >>"${GENTOO_PREFS}" <<-EOF || die "failed to set gfx.font_rendering.graphite.enabled pref"
		sticky_pref("gfx.font_rendering.graphite.enabled", true);
		EOF
	fi

	# Install icons
	local icon_srcdir="${S}/browser/branding/official"

	local icon size
	for icon in "${icon_srcdir}"/default*.png ; do
		size=${icon%.png}
		size=${size##*/default}

		if [[ ${size} -eq 48 ]] ; then
			newicon "${icon}" ${PN}.png
		fi

		newicon -s ${size} "${icon}" ${PN}.png
	done

	# Install menus
	# see https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-browser/RelativeLink/start-tor-browser.desktop
	domenu "${FILESDIR}"/torbrowser.desktop

	# Install wrapper
	# see: https://gitweb.torproject.org/builders/tor-browser-build.git/tree/projects/tor-browser/RelativeLink/start-tor-browser
	# see: https://github.com/Whonix/anon-ws-disable-stacked-tor/blob/master/usr/lib/anon-ws-disable-stacked-tor/torbrowser.sh
	rm "${ED%/}"/usr/bin/torbrowser || die # symlink to /usr/lib64/torbrowser/torbrowser

	newbin - torbrowser <<-EOF
		#!/bin/sh

		unset SESSION_MANAGER
		export GSETTINGS_BACKEND=memory

		export TOR_HIDE_UPDATE_CHECK_UI=1
		export TOR_NO_DISPLAY_NETWORK_SETTINGS=1
		export TOR_SKIP_CONTROLPORTTEST=1
		export TOR_SKIP_LAUNCH=1

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

	# see: https://trac.torproject.org/projects/tor/ticket/11751#comment:2
	# see: https://github.com/Whonix/anon-ws-disable-stacked-tor/blob/master/usr/lib/anon-ws-disable-stacked-tor/torbrowser.sh
	dodoc "${FILESDIR}/99torbrowser.example"

	dodoc "${WORKDIR}/profile/Browser/TorBrowser/Docs/ChangeLog.txt"
}

pkg_preinst() {
	xdg_pkg_preinst

	# If the apulse libs are available in MOZILLA_FIVE_HOME then apulse
	# does not need to be forced into the LD_LIBRARY_PATH
	if use pulseaudio && has_version ">=media-sound/apulse-0.1.12-r4" ; then
		einfo "APULSE found; Generating library symlinks for sound support ..."
		local lib
		pushd "${ED}${MOZILLA_FIVE_HOME}" &>/dev/null || die
		for lib in ../apulse/libpulse{.so{,.0},-simple.so{,.0}} ; do
			# A quickpkg rolled by hand will grab symlinks as part of the package,
			# so we need to avoid creating them if they already exist.
			if [[ ! -L ${lib##*/} ]] ; then
				ln -s "${lib}" ${lib##*/} || die
			fi
		done
		popd &>/dev/null || die
	fi
}

pkg_postinst() {
	xdg_pkg_postinst

	if use pulseaudio && has_version ">=media-sound/apulse-0.1.12-r4" ; then
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
