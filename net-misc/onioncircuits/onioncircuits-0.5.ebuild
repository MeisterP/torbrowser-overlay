# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{5,6} )

inherit gnome2-utils distutils-r1

DESCRIPTION="A GTK application to display Tor circuits and streams"
HOMEPAGE="https://git-tails.immerda.ch/onioncircuits"
SRC_URI="http://ftp.debian.org/debian/pool/main/o/${PN}/${PN}_${PV}.orig.tar.xz"

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

DOCS=( HACKING README README.translators ${FILESDIR}/README.controlport )

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
