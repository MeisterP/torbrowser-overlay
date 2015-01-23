# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 gnome2-utils fdo-mime

DESCRIPTION="A program to download, updated, and run the Tor Browser Bundle"
HOMEPAGE="https://github.com/micahflee/torbrowser-launcher"
SRC_URI="https://github.com/micahflee/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="${PYTHON_DEPS}
	dev-python/pygtk[${PYTHON_USEDEP}]
	dev-python/twisted-core[${PYTHON_USEDEP},crypt]
	dev-python/twisted-web[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}
	app-crypt/gnupg
	dev-python/psutil[${PYTHON_USEDEP}]
	dev-python/pyliblzma[${PYTHON_USEDEP}]
	x11-misc/wmctrl"

python_prepare_all() {
	distutils-r1_python_prepare_all

	# add better icons to desktop files
	sed -i "s/^Icon=.*/Icon=${PN}/" \
		share/applications/torbrowser{,-settings}.desktop || die
}

python_install_all() {
	distutils-r1_python_install_all

	# install icons
	# https://gitweb.torproject.org/torbrowser.git/tree/HEAD:/build-scripts/branding
	local size sizes
	sizes="16 24 32 48 128 256"
	for size in ${sizes}; do
		newicon -s ${size} "${FILESDIR}/icon/${size}.png" ${PN}.png
	done

	# delete apparmor profiles
	rm -r "${D}/etc/apparmor.d" || die "Failed to remove apparmor profiles"
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update

	elog "To get additional features, a number of optional runtime"
	elog "dependencies may be installed:"
	elog ""
	optfeature "updating over system TOR" "net-misc/tor dev-python/txsocksx"
	optfeature "modem sound support" dev-python/pygame
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}
