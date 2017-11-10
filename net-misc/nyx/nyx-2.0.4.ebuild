# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=(python{2_7,3_4,3_5,3_6})
PYTHON_REQ_USE="ncurses"

inherit distutils-r1

DESCRIPTION="Terminal status monitor for Tor"
HOMEPAGE="https://nyx.torproject.org"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND=">=net-libs/stem-1.6.0[${PYTHON_USEDEP}]
	net-vpn/tor"

python_install_all() {
	distutils-r1_python_install_all
	doman nyx.1
	dodoc web/nyxrc.sample
}
