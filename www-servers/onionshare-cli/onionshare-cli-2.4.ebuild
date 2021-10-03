# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7,8,9} )
inherit distutils-r1

DESCRIPTION="Share files, host websites, and chat with friends using the Tor network."
HOMEPAGE="https://onionshare.org/"
SRC_URI="https://github.com/micahflee/onionshare/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="test? ( dev-python/pynacl[${PYTHON_USEDEP}] )"
RDEPEND="dev-python/click[${PYTHON_USEDEP}]
	dev-python/colorama[${PYTHON_USEDEP}]
	dev-python/eventlet[${PYTHON_USEDEP}]
	>=dev-python/flask-1.1.4[${PYTHON_USEDEP}]
	dev-python/flask-httpauth[${PYTHON_USEDEP}]
	>=dev-python/flask-socketio-5.0.1[${PYTHON_USEDEP}]
	dev-python/psutil[${PYTHON_USEDEP}]
	dev-python/pycryptodome[${PYTHON_USEDEP}]
	dev-python/PySocks[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/urllib3[${PYTHON_USEDEP}]
	>=net-libs/stem-1.8.1[${PYTHON_USEDEP}]"
BDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"

DOCS=(README.md)

S=${WORKDIR}/onionshare-${PV}/cli

distutils_enable_tests pytest
