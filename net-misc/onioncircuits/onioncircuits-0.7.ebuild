# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{9..11} )

inherit distutils-r1 xdg

DESCRIPTION="A GTK application to display Tor circuits and streams"
HOMEPAGE="https://gitlab.tails.boum.org/tails/onioncircuits"
SRC_URI="https://gitlab.tails.boum.org/tails/onioncircuits/-/archive/${PV}/onioncircuits-${PV}.tar.bz2"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="${PYTHON_DEPS}
	dev-python/python-distutils-extra[${PYTHON_USEDEP}]"
RDEPEND="${PYTHON_DEPS}
	dev-python/pycountry[${PYTHON_USEDEP}]
	dev-python/pygobject[${PYTHON_USEDEP}]
	net-libs/stem[${PYTHON_USEDEP}]
	>=x11-libs/gtk+-3.14.0:3[introspection]"

DOCS=( HACKING.md README.md README.translators.md "${FILESDIR}"/README.controlport )

src_prepare(){
	default
	rm -r apparmor po || die
}

pkg_postinst() {
	xdg_pkg_postinst
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		elog "Onioncircuits needs acces to a ControlSocket or to a ControlPort."
		elog "See \"${EROOT}/usr/share/doc/${P}/README.controlport\" for"
		elog "more information."
	fi
}
