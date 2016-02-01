# Copyright 1999-2016 Miguel Marco
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit eutils distutils-r1 git-2

DESCRIPTION="Installer of the Tails live system"
HOMEPAGE="https://tails.boum.org"
EGIT_REPO_URI="git://git.tails.boum.org/liveusb-creator"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-python/PyQt4
        app-arch/p7zip
        dev-python/configobj
        dev-python/urlgrabber
        dev-python/python-distutils-extra
        dev-python/pygobject
        dev-python/pyparted
        app-cdr/cdrtools
        sys-boot/syslinux
        sys-apps/gptfdisk"

PATCHES=( "${FILESDIR}"/sgdisk.patch )

