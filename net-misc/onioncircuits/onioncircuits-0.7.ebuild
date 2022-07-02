# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8..11} )

inherit distutils-r1 xdg

DESCRIPTION="A GTK application to display Tor circuits and streams"
HOMEPAGE="https://gitlab.tails.boum.org/tails/onioncircuits"
SRC_URI="https://gitlab.tails.boum.org/tails/onioncircuits/-/archive/${PV}/onioncircuits-${PV}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="${PYTHON_DEPS}
	dev-python/python-distutils-extra[${PYTHON_USEDEP}]"
RDEPEND="${PYTHON_DEPS}
	dev-python/pycountry[${PYTHON_USEDEP}]
	dev-python/pygobject[${PYTHON_USEDEP}]
	net-libs/stem[${PYTHON_USEDEP}]
	>=x11-libs/gtk+-3.14.0:3[introspection]"

DOCS=( HACKING.md README.md README.translators.md ${FILESDIR}/README.controlport )

pkg_postinst() {
	xdg_pkg_postinst
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		elog "Onioncircuits needs acces to a ControlSocket or to a ControlPort."
		elog "See \"${EROOT}/usr/share/doc/${P}/README.controlport\" for"
		elog "more information."
	fi
}
