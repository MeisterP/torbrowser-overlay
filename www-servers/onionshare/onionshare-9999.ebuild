# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python2_7 )
DISTUTILS_SINGLE_IMPL=1

inherit git-r3 distutils-r1 gnome2-utils

DESCRIPTION="Share a file securely and anonymously over Tor"
HOMEPAGE="https://onionshare.org/"
#SRC_URI="https://github.com/micahflee/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
EGIT_REPO_URI="https://github.com/micahflee/${PN}.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND="dev-python/flask[${PYTHON_USEDEP}]
	dev-python/PyQt4[${PYTHON_USEDEP}]
	>=net-libs/stem-1.4.0[${PYTHON_USEDEP}]
	|| ( >=net-misc/tor-0.2.7.1 www-client/torbrowser-launcher )"

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
if [[ -z ${REPLACING_VERSIONS} ]]; then
	elog "Onionshare expects Tor to run on either port 9050 or 9150"
	elog "and a control port accessible on either port 9051 or 9151"
fi

	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
