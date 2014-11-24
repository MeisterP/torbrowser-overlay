# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python{2_7,3_2,3_3,3_4} )

inherit distutils-r1

DESCRIPTION="Use version control tags to discover version numbers"
HOMEPAGE="https://github.com/habnabit/vcversioner"
SRC_URI="https://github.com/habnabit/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

python_prepare_all() {
	echo "${PV}-0-g8541e1b" > version.txt || die
	distutils-r1_python_prepare_all
}
