# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

FIREFOX_PATCHSET="firefox-102esr-patches-10j.tar.xz"

LLVM_MAX_SLOT=15

PYTHON_COMPAT=( python3_{9..11} )
PYTHON_REQ_USE="ncurses,sqlite,ssl"

WANT_AUTOCONF="2.1"

# Convert the ebuild version to the upstream mozilla version, used by mozlinguas
MOZ_PV="${PV/_p*}esr"

# see https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/blob/maint-12.5/projects/firefox/config#L14
# and https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/blob/maint-12.5/projects/browser/config#L106
# and https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/tags
TOR_PV="12.5.1"
TOR_TAG="${TOR_PV%.*}-1-build2"
NOSCRIPT_VERSION="11.4.24"
CHANGELOG_TAG="${TOR_PV}-build1"

inherit autotools check-reqs desktop flag-o-matic linux-info \
	llvm multiprocessing pax-utils python-any-r1 toolchain-funcs xdg

TOR_SRC_BASE_URI="https://dist.torproject.org/torbrowser/${TOR_PV}"
TOR_SRC_ARCHIVE_URI="https://archive.torproject.org/tor-package-archive/torbrowser/${TOR_PV}"

PATCH_URIS=(
	https://dev.gentoo.org/~{juippis,whissi,slashbeast}/mozilla/patchsets/${FIREFOX_PATCHSET}
)

SRC_URI="
	${TOR_SRC_BASE_URI}/src-firefox-tor-browser-${MOZ_PV}-${TOR_TAG}.tar.xz
	${TOR_SRC_ARCHIVE_URI}/src-firefox-tor-browser-${MOZ_PV}-${TOR_TAG}.tar.xz
	https://addons.mozilla.org/firefox/downloads/file/3954910/noscript-${NOSCRIPT_VERSION}.xpi
	https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/raw/tbb-${CHANGELOG_TAG}/projects/browser/Bundle-Data/Docs-TBB/ChangeLog.txt -> ${P}-ChangeLog.txt
	${PATCH_URIS[@]}"

DESCRIPTION="Private browsing without tracking, surveillance, or censorship"
HOMEPAGE="https://www.torproject.org/ https://gitlab.torproject.org/tpo/applications/tor-browser/"

KEYWORDS="~amd64"

SLOT="0"
LICENSE="BSD CC-BY-3.0 MPL-2.0 GPL-2 LGPL-2.1"
IUSE="+clang dbus hardened"
IUSE+=" pulseaudio"
IUSE+=" +system-av1 +system-harfbuzz +system-icu +system-jpeg +system-libevent +system-libvpx system-png system-python-libs +system-webp"
IUSE+=" wayland"

BDEPEND="${PYTHON_DEPS}
	|| (
		(
			sys-devel/clang:15
			sys-devel/llvm:15
			clang? (
				sys-devel/lld:15
				virtual/rust:0/llvm-15
			)
		)
		(
			sys-devel/clang:14
			sys-devel/llvm:14
			clang? (
				sys-devel/lld:14
				virtual/rust:0/llvm-14
			)
		)
	)
	!clang? ( virtual/rust )
	app-arch/unzip
	app-arch/zip
	>=dev-util/cbindgen-0.24.3
	net-libs/nodejs
	virtual/pkgconfig
	>=dev-lang/nasm-2.14"

COMMON_DEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libffi:=
	>=dev-libs/nss-3.79.2
	>=dev-libs/nspr-4.34
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/mesa
	media-video/ffmpeg
	sys-libs/zlib
	virtual/freedesktop-icon-theme
	virtual/opengl
	x11-libs/cairo[X]
	x11-libs/gdk-pixbuf
	x11-libs/gtk+:3[X]
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libXtst
	x11-libs/libxcb:=
	x11-libs/libxkbcommon[X]
	x11-libs/pango
	x11-libs/pixman
	dbus? (
		dev-libs/dbus-glib
		sys-apps/dbus
	)
	pulseaudio? (
		|| (
			media-sound/pulseaudio
			>=media-sound/apulse-0.1.12-r4
		)
	)
	system-av1? (
		>=media-libs/dav1d-1.0.0:=
		>=media-libs/libaom-1.0.0:=
	)
	system-harfbuzz? (
		>=media-gfx/graphite2-1.3.13
		>=media-libs/harfbuzz-2.8.1:0=
	)
	system-icu? ( >=dev-libs/icu-71.1:= )
	system-jpeg? ( >=media-libs/libjpeg-turbo-1.2.1 )
	system-libevent? ( >=dev-libs/libevent-2.1.12:0=[threads(+)] )
	system-libvpx? ( >=media-libs/libvpx-1.8.2:0=[postproc] )
	system-png? ( >=media-libs/libpng-1.6.35:0=[apng] )
	system-webp? ( >=media-libs/libwebp-1.1.0:0= )
	wayland? (
		x11-libs/gtk+:3[wayland]
		x11-libs/libdrm
		x11-libs/libxkbcommon[wayland]
	)"

RDEPEND="${COMMON_DEPEND}
	!www-client/torbrowser-launcher"

DEPEND="${COMMON_DEPEND}
	x11-base/xorg-proto
	x11-libs/libICE
	x11-libs/libSM"

S="${WORKDIR}/firefox-tor-browser-${MOZ_PV}-${TOR_TAG}"

llvm_check_deps() {
	if ! has_version -b "sys-devel/clang:${LLVM_SLOT}" ; then
		einfo "sys-devel/clang:${LLVM_SLOT} is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
		return 1
	fi

	if use clang ; then
		if ! has_version -b "sys-devel/lld:${LLVM_SLOT}" ; then
			einfo "sys-devel/lld:${LLVM_SLOT} is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
			return 1
		fi

		if ! has_version -b "virtual/rust:0/llvm-${LLVM_SLOT}" ; then
			einfo "virtual/rust:0/llvm-${LLVM_SLOT} is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
			return 1
		fi
	fi

	einfo "Using LLVM slot ${LLVM_SLOT} to build" >&2
}

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

moz_install_xpi() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -lt 2 ]] ; then
		die "${FUNCNAME} requires at least two arguments"
	fi

	local DESTDIR=${1}
	shift

	insinto "${DESTDIR}"

	local emid xpi_file xpi_tmp_dir
	for xpi_file in "${@}" ; do
		emid=
		xpi_tmp_dir=$(mktemp -d --tmpdir="${T}")

		# Unpack XPI
		unzip -qq "${xpi_file}" -d "${xpi_tmp_dir}" || die

		# Determine extension ID
		if [[ -f "${xpi_tmp_dir}/install.rdf" ]] ; then
			emid=$(sed -n -e '/install-manifest/,$ { /em:id/!d; s/.*[\">]\([^\"<>]*\)[\"<].*/\1/; p; q }' "${xpi_tmp_dir}/install.rdf")
			[[ -z "${emid}" ]] && die "failed to determine extension id from install.rdf"
		elif [[ -f "${xpi_tmp_dir}/manifest.json" ]] ; then
			emid=$(sed -n -e 's/.*"id": "\([^"]*\)".*/\1/p' "${xpi_tmp_dir}/manifest.json")
			[[ -z "${emid}" ]] && die "failed to determine extension id from manifest.json"
		else
			die "failed to determine extension id"
		fi

		einfo "Installing ${emid}.xpi into ${ED}${DESTDIR} ..."
		newins "${xpi_file}" "${emid}.xpi"
	done
}

mozconfig_add_options_ac() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -lt 2 ]] ; then
		die "${FUNCNAME} requires at least two arguments"
	fi

	local reason=${1}
	shift

	local option
	for option in ${@} ; do
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
	for option in ${@} ; do
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
	CHECKREQS_DISK_BUILD="6400M"

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

	CONFIG_CHECK="~SECCOMP"
	WARNING_SECCOMP="CONFIG_SECCOMP not set! This system will be unable to play DRM-protected content."
	linux-info_pkg_setup
}

src_prepare() {
	rm "${WORKDIR}/firefox-patches/0035-bgo-902025-gcc-13-fixes.patch"
	eapply "${WORKDIR}/firefox-patches"

	# https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/20497#note_2873088
	sed -i \
		-e "s/MOZ_APP_VENDOR=\"Tor Project\"/MOZ_APP_VENDOR=\"TorProject\"/" \
		"${S}"/browser/confvars.sh || die

	# Allow user to apply any additional patches without modifing ebuild
	eapply_user

	# Make cargo respect MAKEOPTS
	export CARGO_BUILD_JOBS="$(makeopts_jobs)"

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

	# Clearing crate checksums where we have applied patches
	moz_clear_vendor_checksums bindgen

	# Create build dir
	BUILD_DIR="${WORKDIR}/${PN}_build"
	mkdir -p "${BUILD_DIR}" || die

	xdg_environment_reset
}

src_configure() {
	# Show flags set at the beginning
	einfo "Current BINDGEN_CFLAGS:\t${BINDGEN_CFLAGS:-no value set}"
	einfo "Current CFLAGS:\t\t${CFLAGS:-no value set}"
	einfo "Current CXXFLAGS:\t\t${CXXFLAGS:-no value set}"
	einfo "Current LDFLAGS:\t\t${LDFLAGS:-no value set}"
	einfo "Current RUSTFLAGS:\t\t${RUSTFLAGS:-no value set}"

	local have_switched_compiler=
	if use clang; then
		# Force clang
		einfo "Enforcing the use of clang due to USE=clang ..."
		if tc-is-gcc; then
			have_switched_compiler=yes
		fi
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
	export AS="$(tc-getCC) -c"
	tc-export CC CXX LD AR AS NM OBJDUMP RANLIB PKG_CONFIG

	# Pass the correct toolchain paths through cbindgen
	if tc-is-cross-compiler ; then
		export BINDGEN_CFLAGS="${SYSROOT:+--sysroot=${ESYSROOT}} --target=${CHOST} ${BINDGEN_CFLAGS-}"
	fi

	# Set MOZILLA_FIVE_HOME
	export MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"

	# python/mach/mach/mixin/process.py fails to detect SHELL
	export SHELL="${EPREFIX}/bin/bash"

	# Set state path
	export MOZBUILD_STATE_PATH="${BUILD_DIR}"

	# Set MOZCONFIG
	export MOZCONFIG="${S}/.mozconfig"

	# Initialize MOZCONFIG
	mozconfig_add_options_ac '' --enable-application=browser

	# Set Gentoo defaults
	export MOZILLA_OFFICIAL=1

	mozconfig_add_options_ac 'Gentoo default' \
		--allow-addon-sideload \
		--disable-cargo-incremental \
		--disable-crashreporter \
		--disable-gpsd \
		--disable-install-strip \
		--disable-parental-controls \
		--disable-strip \
		--disable-updater \
		--enable-negotiateauth \
		--enable-new-pass-manager \
		--enable-official-branding \
		--enable-release \
		--enable-system-ffi \
		--enable-system-pixman \
		--host="${CBUILD:-${CHOST}}" \
		--libdir="${EPREFIX}/usr/$(get_libdir)" \
		--prefix="${EPREFIX}/usr" \
		--target="${CHOST}" \
		--without-ccache \
		--without-wasm-sandboxed-libraries \
		--with-intl-api \
		--with-libclang-path="$(llvm-config --libdir)" \
		--with-system-nspr \
		--with-system-nss \
		--with-system-zlib \
		--with-toolchain-prefix="${CHOST}-" \
		--with-unsigned-addon-scopes=app,system \
		--x-includes="${ESYSROOT}/usr/include" \
		--x-libraries="${ESYSROOT}/usr/$(get_libdir)"

	mozconfig_add_options_ac '' --enable-rust-simd

	mozconfig_use_with system-av1
	mozconfig_use_with system-harfbuzz
	mozconfig_use_with system-harfbuzz system-graphite2
	mozconfig_use_with system-icu
	mozconfig_use_with system-jpeg
	mozconfig_use_with system-libevent
	mozconfig_use_with system-libvpx
	mozconfig_use_with system-png
	mozconfig_use_with system-webp

	mozconfig_use_enable dbus
	mozconfig_add_options_ac ''  --disable-libproxy

	mozconfig_add_options_ac '' --disable-eme

	mozconfig_add_options_ac '' --disable-geckodriver

	if use hardened ; then
		mozconfig_add_options_ac "+hardened" --enable-hardening
		append-ldflags "-Wl,-z,relro -Wl,-z,now"
	fi

	local myaudiobackends=""
	use pulseaudio && myaudiobackends+="pulseaudio,"
	! use pulseaudio && myaudiobackends+="alsa,"

	mozconfig_add_options_ac '--enable-audio-backends' --enable-audio-backends="${myaudiobackends::-1}"

	mozconfig_add_options_ac '' --disable-necko-wifi

	if use wayland ; then
		mozconfig_add_options_ac '+x11+wayland' --enable-default-toolkit=cairo-gtk3-x11-wayland
	else
		mozconfig_add_options_ac '+x11' --enable-default-toolkit=cairo-gtk3
	fi

	# see https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/issues/40745
	export MOZ_APP_BASENAME="TorBrowser"

	# see https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/blob/maint-12.5/projects/firefox/build?ref_type=heads#L174
	mozconfig_add_options_ac 'torbrowser' \
		--with-base-browser-version=${TOR_PV} \
		--enable-update-channel=release \
		--with-branding=browser/branding/tb-release

	# see https://gitlab.torproject.org/tpo/applications/tor-browser/-/blob/tor-browser-102.9.0esr-12.5-1/browser/config/mozconfigs/tor-browser
	mozconfig_add_options_mk 'torbrowser' "MOZ_APP_DISPLAYNAME=\"Tor Browser\""
	mozconfig_add_options_ac 'torbrowser' \
		--without-relative-data-dir \
		--with-distribution-id=org.torproject

	# see https://gitlab.torproject.org/tpo/applications/tor-browser/-/blob/tor-browser-102.9.0esr-12.5-1/browser/config/mozconfigs/base-browser
	export MOZILLA_OFFICIAL=1
	mozconfig_add_options_ac 'torbrowser' \
		--enable-official-branding

	# see https://gitlab.torproject.org/tpo/applications/tor-browser/-/blob/tor-browser-102.9.0esr-12.5-1/mozconfig-linux-x86_64
	mozconfig_add_options_ac 'torbrowser' \
		--disable-strip \
		--disable-install-strip

	# see https://gitlab.torproject.org/tpo/applications/tor-browser/-/blob/tor-browser-102.9.0esr-12.5-1/browser/config/mozconfigs/base-browser
	mozconfig_add_options_ac 'torbrowser' \
		--enable-optimize \
		--enable-rust-simd \
		--enable-verify-mar \
		--enable-nss-mar \
		--disable-base-browser-update \
		--enable-bundled-fonts \
		--disable-tests \
		--disable-debug \
		--disable-crashreporter \
		--disable-webrtc \
		--disable-parental-controls \
		--disable-eme \
		--enable-proxy-bypass-protection \
		--disable-system-policies \
		--disable-backgroundtasks \
		MOZ_TELEMETRY_REPORTING= \
		--without-wasm-sandboxed-libraries

	# Avoid auto-magic on linker
	if use clang ; then
		# This is upstream's default
		mozconfig_add_options_ac "forcing ld=lld due to USE=clang" --enable-linker=lld
	else
		mozconfig_add_options_ac "linker is set to bfd" --enable-linker=bfd
	fi

	# LTO flag was handled via configure
	filter-flags '-flto*'

	mozconfig_add_options_ac 'Gentoo default' --disable-debug-symbols

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

	if use clang ; then
		# https://bugzilla.mozilla.org/show_bug.cgi?id=1482204
		# https://bugzilla.mozilla.org/show_bug.cgi?id=1483822
		# toolkit/moz.configure Elfhack section: target.cpu in ('arm', 'x86', 'x86_64')
		local disable_elf_hack=
		if use amd64 ; then
			disable_elf_hack=yes
		fi

		if [[ -n ${disable_elf_hack} ]] ; then
			mozconfig_add_options_ac 'elf-hack is broken when using Clang' --disable-elf-hack
		fi
	elif tc-is-gcc ; then
		if ver_test $(gcc-fullversion) -ge 10 ; then
			einfo "Forcing -fno-tree-loop-vectorize to workaround GCC bug, see bug 758446 ..."
			append-cxxflags -fno-tree-loop-vectorize
		fi
	fi

	if ! use elibc_glibc ; then
		mozconfig_add_options_ac '!elibc_glibc' --disable-jemalloc
	fi

	# Allow elfhack to work in combination with unstripped binaries
	# when they would normally be larger than 2GiB.
	append-ldflags "-Wl,--compress-debug-sections=zlib"

	# Make revdep-rebuild.sh happy; Also required for musl
	append-ldflags -Wl,-rpath="${MOZILLA_FIVE_HOME}",--enable-new-dtags

	# Pass $MAKEOPTS to build system
	export MOZ_MAKE_FLAGS="${MAKEOPTS}"

	# Use system's Python environment
	export PIP_NETWORK_INSTALL_RESTRICTED_VIRTUALENVS=mach

	if use system-python-libs; then
		export MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE="system"
	else
		export MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE="none"
	fi

	# Disable notification when build system has finished
	export MOZ_NOSPAM=1

	# Portage sets XARGS environment variable to "xargs -r" by default which
	# breaks build system's check_prog() function which doesn't support arguments
	mozconfig_add_options_ac 'Gentoo default' "XARGS=${EPREFIX}/usr/bin/xargs"

	# Set build dir
	mozconfig_add_options_mk 'Gentoo default' "MOZ_OBJDIR=${BUILD_DIR}"

	# Show flags we will use
	einfo "Build BINDGEN_CFLAGS:\t${BINDGEN_CFLAGS:-no value set}"
	einfo "Build CFLAGS:\t\t${CFLAGS:-no value set}"
	einfo "Build CXXFLAGS:\t\t${CXXFLAGS:-no value set}"
	einfo "Build LDFLAGS:\t\t${LDFLAGS:-no value set}"
	einfo "Build RUSTFLAGS:\t\t${RUSTFLAGS:-no value set}"

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
	./mach build --verbose || die

	# FIXME: add locale support
	# see https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/blob/main/projects/firefox/build#L184
	export MOZ_CHROME_MULTILOCALE=""
	./mach package-multi-locale --locales en-US $MOZ_CHROME_MULTILOCALE || die
	AB_CD=multi ./mach build stage-package || die
}

src_install() {
	# xpcshell is getting called during install
	pax-mark m \
		"${BUILD_DIR}"/dist/bin/xpcshell \
		"${BUILD_DIR}"/dist/bin/${PN} \
		"${BUILD_DIR}"/dist/bin/plugin-container

	DESTDIR="${D}" ./mach install || die

	# Upstream cannot ship symlink but we can (bmo#658850)
	rm "${ED}${MOZILLA_FIVE_HOME}/${PN}-bin" || die
	dosym ${PN} ${MOZILLA_FIVE_HOME}/${PN}-bin

	# Don't install llvm-symbolizer from sys-devel/llvm package
	if [[ -f "${ED}${MOZILLA_FIVE_HOME}/llvm-symbolizer" ]] ; then
		rm -v "${ED}${MOZILLA_FIVE_HOME}/llvm-symbolizer" || die
	fi

	# https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/blob/main/projects/browser/build#L65
	insinto ${MOZILLA_FIVE_HOME}/browser/extensions
	newins "${DISTDIR}/noscript-${NOSCRIPT_VERSION}.xpi" {73a6fe31-595d-460b-a920-fcc0f8843232}.xpi

	# Install system-wide preferences
	local PREFS_DIR="${MOZILLA_FIVE_HOME}/browser/defaults/preferences"
	insinto "${PREFS_DIR}"

	local GENTOO_PREFS="${ED}${PREFS_DIR}/gentoo-prefs.js"

	# Set dictionary path to use system hunspell
	cat >>"${GENTOO_PREFS}" <<-EOF || die "failed to set spellchecker.dictionary_path pref"
	pref("spellchecker.dictionary_path",       "${EPREFIX}/usr/share/myspell");
	EOF

	# Force the graphite pref if USE=system-harfbuzz is enabled, since the pref cannot disable it
	if use system-harfbuzz ; then
		cat >>"${GENTOO_PREFS}" <<-EOF || die "failed to set gfx.font_rendering.graphite.enabled pref"
		sticky_pref("gfx.font_rendering.graphite.enabled", true);
		EOF
	fi

	# Install icons
	local icon_srcdir="${S}/browser/branding/tb-release"

	local icon size
	for icon in "${icon_srcdir}"/default*.png ; do
		size=${icon%.png}
		size=${size##*/default}

		if [[ ${size} -eq 48 ]] ; then
			newicon "${icon}" ${PN}.png
		fi

		newicon -s ${size} "${icon}" ${PN}.png
	done

	# Install menu
	# see https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/blob/main/projects/browser/RelativeLink/start-browser.desktop
	domenu "${FILESDIR}"/torbrowser.desktop

	# Install wrapper
	# see: https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/blob/main/projects/browser/RelativeLink/start-browser
	# see: https://github.com/Whonix/anon-ws-disable-stacked-tor/blob/master/usr/libexec/anon-ws-disable-stacked-tor/torbrowser.sh
	rm "${ED}"/usr/bin/torbrowser || die # symlink to /usr/lib64/torbrowser/torbrowser

	newbin - torbrowser <<-EOF
		#!/bin/bash

		unset SESSION_MANAGER
		export GSETTINGS_BACKEND=memory

		export TOR_SKIP_LAUNCH=1
		export TOR_SKIP_CONTROLPORTTEST=1

		if @DEFAULT_WAYLAND@ && [[ -z \${MOZ_DISABLE_WAYLAND} ]]; then
			if [[ -n "\${WAYLAND_DISPLAY}" ]]; then
				export MOZ_ENABLE_WAYLAND=1
			fi
		fi

		exec /usr/$(get_libdir)/torbrowser/torbrowser --class "Tor Browser" --name "Tor Browser" "\${@}"
	EOF

	# Update wrapper
	local use_wayland="false"
	if use wayland ; then
		use_wayland="true"
	fi
	sed -i -e "s:@DEFAULT_WAYLAND@:${use_wayland}:" "${ED}/usr/bin/${PN}" || die

	# torbrowser and torbrowser-bin are identical
	rm "${ED}"${MOZILLA_FIVE_HOME}/torbrowser-bin || die
	dosym torbrowser ${MOZILLA_FIVE_HOME}/torbrowser-bin

	# see https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/blob/main/projects/browser/Bundle-Data/Docs/ChangeLog.txt
	newdoc "${DISTDIR}/${P}-ChangeLog.txt" ChangeLog.txt

	# see: https://github.com/Whonix/anon-ws-disable-stacked-tor/blob/master/usr/libexec/anon-ws-disable-stacked-tor/torbrowser.sh
	dodoc "${FILESDIR}/99torbrowser.example"
	dodoc "${FILESDIR}/torrc.example"
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

	if [[ -z "${REPLACING_VERSIONS}" ]] ; then
		ewarn "This Tor Browser build is _NOT_ recommended by Tor upstream but uses"
		ewarn "the exact same sources. Use this only if you know what you are doing!"
		elog "Torbrowser uses port 9150 to connect to Tor. You can change the port"
		elog "in /etc/env.d/99torbrowser to match your setup."
		elog "An example file is available at /usr/share/doc/${P}/99torbrowser.example.bz2"
		elog ""
		elog "To get the advanced functionality (network information,"
		elog "new identity), Torbrowser needs to access a control port."
		elog "Set the Variables in /etc/env.d/99torbrowser accordingly."
	fi

	if [[ "${REPLACING_VERSIONS}" ]] && [[ "${REPLACING_VERSIONS}" < "102.7.0_p12500_alpha7" ]]; then
		ewarn "With this update, the profile directory moved from \"~/.mozilla/torbrowser/\""
		ewarn "to \"~/.torproject/torbrowser/\". To keep your settings and bookmarks,"
		ewarn "move your profile to the new location before launching torbrowser"
	fi
}
