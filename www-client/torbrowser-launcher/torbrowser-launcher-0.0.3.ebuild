# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 gnome2-utils

DESCRIPTION="A program to download, updated, and run the Tor Browser Bundle"
HOMEPAGE="https://github.com/micahflee/torbrowser-launcher"
SRC_URI="https://github.com/micahflee/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="${PYTHON_DEPS}
	dev-python/pygtk[${PYTHON_USEDEP}]
	dev-python/twisted-core[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}
	app-crypt/gnupg
	dev-python/psutil[${PYTHON_USEDEP}]
	dev-python/pyliblzma[${PYTHON_USEDEP}]
	x11-misc/wmctrl"

python_prepare() {
	distutils-r1_python_prepare

	# add better icons to desktop files
	sed -i "s/^Icon=.*/Icon=${PN}/" \
		torbrowser{,-settings}.desktop  || die
}

python_install() {
	distutils-r1_python_install

	# install icons
	# https://gitweb.torproject.org/torbrowser.git/tree/HEAD:/build-scripts/branding
	local size sizes
	sizes="16 24 32 48 128 256"
	for size in ${sizes}; do
		newicon -s ${size} "${FILESDIR}/icon/${size}.png" ${PN}.png
	done
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
