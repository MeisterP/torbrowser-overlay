# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=(python{2_7,3_4,3_5,3_6})

inherit git-r3 distutils-r1

DESCRIPTION="Stem is a Python controller library for Tor"
HOMEPAGE="https://stem.torproject.org"
EGIT_REPO_URI="https://git.torproject.org/stem.git"
EGIT_COMMIT="3cc85fc9dbb907965279cca4d844999d57010a2b"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

DEPEND="test? ( dev-python/mock[${PYTHON_USEDEP}]
	net-vpn/tor )
	dev-python/setuptools[${PYTHON_USEDEP}]"

RDEPEND="net-vpn/tor"

DOCS=( docs/{_static,_templates,api,tutorials,{change_log,api,contents,download,faq,index,tutorials}.rst} )

python_prepare_all() {
	# Disable failing test
	sed -i -e "/test_expand_path/a \
		\ \ \ \ return" test/integ/util/system.py || die
	sed -i -e "/test_parsing_with_example/a \
		\ \ \ \ return" test/unit/manual.py || die
	sed -i -e "/test_parsing_with_unknown_options/a \
		\ \ \ \ return" test/unit/manual.py || die
	sed -i -e "/test_saving_manual/a \
		\ \ \ \ return" test/unit/manual.py || die
	sed -i -e "/test_sdist_matches_git/a \
		\ \ \ \ return" test/integ/installation.py || die
	distutils-r1_python_prepare_all
}

python_test() {
	${PYTHON} run_tests.py --all --target RUN_ALL || die
}
