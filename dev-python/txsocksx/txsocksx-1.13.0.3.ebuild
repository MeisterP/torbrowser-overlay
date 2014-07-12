# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1

DESCRIPTION="Twisted client endpoints for SOCKS{4,4a,5}"
HOMEPAGE="https://github.com/habnabit/txsocksx"
SRC_URI="https://github.com/habnabit/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-python/vcversioner[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}
	>=dev-python/parsley-1.2[${PYTHON_USEDEP}]
	dev-python/pyopenssl[${PYTHON_USEDEP}]
	dev-python/twisted-core[${PYTHON_USEDEP},crypt]
	dev-python/twisted-web[${PYTHON_USEDEP}]"

python_prepare_all() {
	echo "${PV}-0-g1fb0462" > version.txt || die
	distutils-r1_python_prepare_all
}
