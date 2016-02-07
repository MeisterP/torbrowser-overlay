# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3 systemd

MY_PN="${PN/_/.}"

DESCRIPTION="Refresh your GnuPG keyring without disclosing your whole contact list"
HOMEPAGE="https://github.com/EtiennePerot/parcimonie.sh"
SRC_URI=""
EGIT_REPO_URI="https://github.com/EtiennePerot/${MY_PN}.git"

LICENSE="WTFPL-2"
SLOT="0"
KEYWORDS=""

RDEPEND="app-crypt/gpgme
	app-shells/bash
	net-misc/tor
	>=net-proxy/torsocks-2.0.0"

src_install() {
	dobin ${MY_PN}
	dodoc README.md

	insinto etc/${MY_PN}.d/
	doins pkg/all-users.conf pkg/sample-configuration.conf.sample

	systemd_dounit pkg/${MY_PN}@.service
}
