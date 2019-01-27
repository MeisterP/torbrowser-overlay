# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{5,6} )

inherit distutils-r1

MY_PV=${PV/_pre/.dev}

DESCRIPTION="Securely and anonymously send and receive files over Tor"
HOMEPAGE="https://onionshare.org/"
SRC_URI="https://github.com/micahflee/onionshare/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="nautilus test"

DEPEND="${PYTHON_DEPS}
	test? ( dev-python/pycrypto[${PYTHON_USEDEP}]
		dev-python/PyQt5[${PYTHON_USEDEP},testlib]
		dev-python/pytest[${PYTHON_USEDEP}] )"
RDEPEND="${PYTHON_DEPS}
	dev-python/flask[${PYTHON_USEDEP}]
	dev-python/pycrypto[${PYTHON_USEDEP}]
	dev-python/PyQt5[${PYTHON_USEDEP}]
	dev-python/PySocks[${PYTHON_USEDEP}]
	>=net-libs/stem-1.6.0[${PYTHON_USEDEP}]
	>=net-vpn/tor-0.2.7.1
	nautilus? ( dev-python/nautilus-python )"

PATCHES=( ${FILESDIR}/onionshare-1.3.1_nautilus_shebang.patch )

S=${WORKDIR}/onionshare-${MY_PV}

python_test() {
	${EPYTHON} -m pytest tests/ || die
}
