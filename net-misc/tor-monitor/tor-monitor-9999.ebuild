# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit gnome2-utils git-r3 distutils-r1

DESCRIPTION="A GTK application to display Tor circuits and streams"
HOMEPAGE="http://git.tails.boum.org/alan/tor-monitor/"
EGIT_REPO_URI="git://git.tails.boum.org/alan/tor-monitor"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="${PYTHON_DEPS}
	dev-python/python-distutils-extra[${PYTHON_USEDEP}]"
RDEPEND="${PYTHON_DEPS}
	dev-python/pycountry[${PYTHON_USEDEP}]
	dev-python/pygobject[${PYTHON_USEDEP}]
	net-libs/stem[${PYTHON_USEDEP}]
	>=x11-libs/gtk+-3.14.0:3[introspection]"

PATCHES=( ${FILESDIR}/fix-icon.patch )

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
	elog "Tormonitor needs acces to the ControlSocket"
	elog "at \"/var/run/tor/control\""
	elog "See \"man tor\" on how to configure the ControlSocket"
}

pkg_postrm() {
	gnome2_icon_cache_update
}
