# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7,8,9} )
inherit distutils-r1

DESCRIPTION="The bidirectional mapping library for Python."
HOMEPAGE="https://pypi.org/project/bidict/ https://github.com/jab/bidict"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"

# pypi tarball does not contain tests
RESTRICT="test"
