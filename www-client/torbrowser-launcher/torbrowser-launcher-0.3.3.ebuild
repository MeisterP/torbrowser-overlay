# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_SETUPTOOLS=no

inherit distutils-r1 gnome2-utils xdg-utils

DESCRIPTION="A program to download, updated, and run the Tor Browser Bundle"
HOMEPAGE="https://github.com/micahflee/torbrowser-launcher"
SRC_URI="https://github.com/micahflee/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

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
	$(python_gen_cond_dep '
		dev-python/distro[${PYTHON_MULTI_USEDEP}]
	')"

RDEPEND="${PYTHON_DEPS}
	$(python_gen_cond_dep '
		app-crypt/gpgme[python,${PYTHON_MULTI_USEDEP}]
		dev-python/packaging[${PYTHON_MULTI_USEDEP}]
		dev-python/PyQt5[${PYTHON_MULTI_USEDEP},widgets]
		dev-python/PySocks[${PYTHON_MULTI_USEDEP}]
		dev-python/requests[${PYTHON_MULTI_USEDEP}]
	')
	${FIREFOX_BIN}"

PATCHES=(
	# https://github.com/micahflee/torbrowser-launcher/pull/484
	"${FILESDIR}"/Changed_platform_to_distro_or_Python3.patch
	)

python_install_all() {
	distutils-r1_python_install_all

	# delete apparmor profiles
	rm -r "${D}/etc/apparmor.d" || die "Failed to remove apparmor profiles"
	rmdir "${D}/etc" || die "Failed to remove empty directory"
}

pkg_postinst() {
	xdg_mimeinfo_database_update
	gnome2_icon_cache_update

	elog "To get additional features, a number of optional runtime"
	elog "dependencies may be installed:"
	elog ""
	optfeature "updating over system TOR" "net-vpn/tor dev-python/txsocksx"
}

pkg_postrm() {
	xdg_mimeinfo_database_update
	gnome2_icon_cache_update
}
