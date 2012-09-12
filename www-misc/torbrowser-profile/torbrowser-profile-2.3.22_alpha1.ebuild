# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

MY_PN=torbrowser
MY_PV="${PV/_alpha/-alpha-}"

DESCRIPTION="Profile folder from the torbrowser bundle"
HOMEPAGE="https://www.torproject.org/dist/torbrowser/linux/"
SRC_URI="amd64? ( https://www.torproject.org/dist/${MY_PN}/linux/tor-browser-gnu-linux-x86_64-${MY_PV}-dev-en-US.tar.gz )
	x86? ( https://www.torproject.org/dist/${MY_PN}/linux/tor-browser-gnu-linux-i686-${MY_PV}-dev-en-US.tar.gz )"

LICENSE="BSD GPL-2 MIT"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="www-client/torbrowser"

S=${WORKDIR}/tor-browser_en-US

src_install() {
	insinto /usr/share/${MY_PN}
	doins -r Data/profile
	dodoc Docs/changelog
}
