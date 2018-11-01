# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{4,5,6} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 gnome2-utils xdg-utils

DESCRIPTION="A program to download, updated, and run the Tor Browser Bundle"
HOMEPAGE="https://github.com/micahflee/torbrowser-launcher"
SRC_URI="https://github.com/micahflee/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="${PYTHON_DEPS}
	app-crypt/gpgme[python,${PYTHON_USEDEP}]
	dev-python/PyQt5[${PYTHON_USEDEP}]
	dev-python/PySocks[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]"
DEPEND="${PYTHON_DEPS}"

python_install_all() {
	distutils-r1_python_install_all

	# delete apparmor profiles
	rm -r "${D}/etc/apparmor.d" || die "Failed to remove apparmor profiles"
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
