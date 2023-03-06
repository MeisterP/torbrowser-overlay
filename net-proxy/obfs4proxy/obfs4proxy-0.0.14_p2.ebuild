# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

EGO_SUM=(
	"filippo.io/edwards25519 v1.0.0-rc.1.0.20210721174708-390f27c3be20"
	"filippo.io/edwards25519 v1.0.0-rc.1.0.20210721174708-390f27c3be20/go.mod"
	"git.torproject.org/pluggable-transports/goptlib.git v1.0.0"
	"git.torproject.org/pluggable-transports/goptlib.git v1.0.0/go.mod"
	"github.com/andybalholm/brotli v1.0.4"
	"github.com/andybalholm/brotli v1.0.4/go.mod"
	"github.com/dchest/siphash v1.2.1"
	"github.com/dchest/siphash v1.2.1/go.mod"
	"github.com/klauspost/compress v1.15.9"
	"github.com/klauspost/compress v1.15.9/go.mod"
	"github.com/refraction-networking/utls v1.1.5"
	"github.com/refraction-networking/utls v1.1.5/go.mod"
	"gitlab.com/yawning/edwards25519-extra.git v0.0.0-20211229043746-2f91fcc9fbdb"
	"gitlab.com/yawning/edwards25519-extra.git v0.0.0-20211229043746-2f91fcc9fbdb/go.mod"
	"golang.org/x/crypto v0.0.0-20210711020723-a769d52b0f97"
	"golang.org/x/crypto v0.0.0-20210711020723-a769d52b0f97/go.mod"
	"golang.org/x/crypto v0.0.0-20220829220503-c86fa9a7ed90"
	"golang.org/x/crypto v0.0.0-20220829220503-c86fa9a7ed90/go.mod"
	"golang.org/x/net v0.0.0-20210226172049-e18ecbb05110"
	"golang.org/x/net v0.0.0-20210226172049-e18ecbb05110/go.mod"
	"golang.org/x/net v0.0.0-20211112202133-69e39bad7dc2/go.mod"
	"golang.org/x/net v0.0.0-20220909164309-bea034e7d591"
	"golang.org/x/net v0.0.0-20220909164309-bea034e7d591/go.mod"
	"golang.org/x/sys v0.0.0-20201119102817-f84b799fce68/go.mod"
	"golang.org/x/sys v0.0.0-20210423082822-04245dca01da/go.mod"
	"golang.org/x/sys v0.0.0-20210615035016-665e8c7367d1"
	"golang.org/x/sys v0.0.0-20210615035016-665e8c7367d1/go.mod"
	"golang.org/x/sys v0.0.0-20220728004956-3c1f35247d10"
	"golang.org/x/sys v0.0.0-20220728004956-3c1f35247d10/go.mod"
	"golang.org/x/term v0.0.0-20201126162022-7de9c90e9dd1/go.mod"
	"golang.org/x/term v0.0.0-20210927222741-03fcf44c2211/go.mod"
	"golang.org/x/text v0.3.3/go.mod"
	"golang.org/x/text v0.3.6/go.mod"
	"golang.org/x/text v0.3.7"
	"golang.org/x/text v0.3.7/go.mod"
	"golang.org/x/tools v0.0.0-20180917221912-90fa682c2a6e/go.mod"
	)
go-module_set_globals

MY_PV=${PV/_p/-tor}

DESCRIPTION="Obfs4 is a pluggable transport that makes Tor traffic look random"
HOMEPAGE="https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/obfs4"
SRC_URI="https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/obfs4/-/archive/obfs4proxy-${MY_PV}/obfs4-obfs4proxy-${MY_PV}.tar.bz2
	${EGO_SUM_SRC_URI}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

S=${WORKDIR}/obfs4-obfs4proxy-${MY_PV}

src_compile() {
	pushd obfs4proxy > /dev/null || die
		ego build
	popd > /dev/null || die
}

src_install() {
	dobin obfs4proxy/obfs4proxy

	doman doc/obfs4proxy.1

	sed -i -e "s|/usr/local/bin/obfs4proxy|/usr/bin/obfs4proxy|" README.md || die
	dodoc ChangeLog README.md
}
