# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7,8,9} )

inherit distutils-r1 xdg

DESCRIPTION="A program to download, updated, and run the Tor Browser Bundle"
HOMEPAGE="https://github.com/micahflee/torbrowser-launcher"
SRC_URI="https://github.com/micahflee/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="apparmor"

FIREFOX_BIN="dev-libs/atk
	>=sys-apps/dbus-0.60
	>=dev-libs/dbus-glib-0.72
	>=dev-libs/glib-2.26:2
	media-libs/fontconfig
	>=media-libs/freetype-2.4.10
	>=x11-libs/cairo-1.10[X]
	x11-libs/gdk-pixbuf
	>=x11-libs/gtk+-3.4.0:3
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrender
	x11-libs/libXt
	>=x11-libs/pango-1.22.0

	dev-libs/libevent"

DEPEND="${PYTHON_DEPS}
	dev-python/distro[${PYTHON_USEDEP}]"

RDEPEND="${PYTHON_DEPS}
	app-crypt/gpgme[python,${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	dev-python/PyQt5[${PYTHON_USEDEP},widgets]
	dev-python/PySocks[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	${FIREFOX_BIN}
	apparmor? ( sys-libs/libapparmor )"

PATCHES=(
	# https://github.com/micahflee/torbrowser-launcher/pull/484
	"${FILESDIR}"/Changed_platform_to_distro_or_Python3.patch
	)

python_install_all() {
	distutils-r1_python_install_all

	# delete apparmor profiles
	if ! use apparmor; then
		rm -r "${D}/etc/apparmor.d" || die "Failed to remove apparmor profiles"
		rmdir "${D}/etc" || die "Failed to remove empty directory"
	fi
}

pkg_postinst() {
	xdg_pkg_postinst
	elog "For updating over system TOR install net-vpn/tor and dev-python/txsocksx"
}
