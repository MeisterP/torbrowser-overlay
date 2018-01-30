# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 gnome2-utils xdg-utils

DESCRIPTION="A program to download, updated, and run the Tor Browser Bundle"
HOMEPAGE="https://github.com/micahflee/torbrowser-launcher"
SRC_URI="https://github.com/micahflee/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="${PYTHON_DEPS}
	dev-python/pygtk:2[${PYTHON_USEDEP}]
	|| (
		>=dev-python/twisted-16.0.0[${PYTHON_USEDEP},crypt]
		>=dev-python/twisted-core-14.0.1[${PYTHON_USEDEP},crypt]
	)
	|| (
		>=dev-python/twisted-16.0.0[${PYTHON_USEDEP}]
		>=dev-python/twisted-web-14.0.1[${PYTHON_USEDEP}]
	)"
RDEPEND="${DEPEND}
	app-crypt/gpgme[${PYTHON_USEDEP}]
	dev-python/psutil[${PYTHON_USEDEP}]
	dev-python/pyliblzma[${PYTHON_USEDEP}]"

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
	optfeature "modem sound support" dev-python/pygame
}

pkg_postrm() {
	xdg_mimeinfo_database_update
	gnome2_icon_cache_update
}
