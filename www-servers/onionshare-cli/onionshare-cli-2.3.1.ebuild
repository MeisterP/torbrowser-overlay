# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7,8,9} )
inherit distutils-r1

DESCRIPTION="Share files, host websites, and chat with friends using the Tor network."
HOMEPAGE="https://onionshare.org/ https://pypi.org/project/onionshare-cli/"
SRC_URI="mirror://pypi/o/onionshare_cli/onionshare_cli-${PV}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=""
RDEPEND="${DEPEND}
	dev-python/click[${PYTHON_USEDEP}]
	dev-python/eventlet[${PYTHON_USEDEP}]
	dev-python/flask-httpauth[${PYTHON_USEDEP}]
	dev-python/flask-socketio[${PYTHON_USEDEP}]
	dev-python/psutil[${PYTHON_USEDEP}]
	dev-python/pycryptodome[${PYTHON_USEDEP}]
	dev-python/PySocks[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/urllib3[${PYTHON_USEDEP}]
	net-libs/stem[${PYTHON_USEDEP}]"
BDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"

# pypi tarball does not contain tests
RESTRICT="test"

S=${WORKDIR}/onionshare_cli-${PV}
