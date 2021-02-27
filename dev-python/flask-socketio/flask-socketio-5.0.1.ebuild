# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7,8,9} )
inherit distutils-r1

DESCRIPTION="Socket.IO integration for Flask applications."
HOMEPAGE="https://flask-socketio.readthedocs.org/ https://github.com/miguelgrinberg/Flask-SocketIO/ https://pypi.org/project/Flask-SocketIO/"
SRC_URI="mirror://pypi/F/Flask-SocketIO/Flask-SocketIO-${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-python/flask-0.9[${PYTHON_USEDEP}]
	>=dev-python/python-socketio-5.0.2[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}"
BDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"

# pypi tarball does not contain tests
RESTRICT="test"

S="${WORKDIR}/Flask-SocketIO-${PV}"
