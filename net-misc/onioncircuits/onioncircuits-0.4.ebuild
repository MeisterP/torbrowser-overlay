# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python{2_7,3_3,3_4} )

inherit gnome2-utils distutils-r1

DESCRIPTION="A GTK application to display Tor circuits and streams"
HOMEPAGE="https://git-tails.immerda.ch/onioncircuits"
SRC_URI="http://http.debian.net/debian/pool/main/o/${PN}/${PN}_${PV}.orig.tar.gz"

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

DOCS=( README README.translators ${FILESDIR}/README.controlport )

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		elog "Onioncircuits needs acces to a ControlSocket or to a ControlPort."
		elog "See \"${EROOT}usr/share/doc/${P}/README.controlport\" for"
		elog "more information."
	fi
}

pkg_postrm() {
	gnome2_icon_cache_update
}
