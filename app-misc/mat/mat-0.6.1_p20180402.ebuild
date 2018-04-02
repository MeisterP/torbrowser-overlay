# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit distutils-r1 vcs-snapshot

DESCRIPTION="Metadata Anonymisation Toolkit"
HOMEPAGE="https://mat.boum.org/"
SRC_URI="https://0xacab.org/mat/mat/repository/4b9a65758da4bb27724ac1f94162810a29cb3877/archive.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+audio +exif nautilus +pdf"

DEPEND="dev-python/python-distutils-extra[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}
	audio? ( media-libs/mutagen[${PYTHON_USEDEP}] )
	exif? ( media-libs/exiftool )
	nautilus? ( dev-python/nautilus-python[${PYTHON_USEDEP}] )
	pdf? ( dev-python/pdfrw[${PYTHON_USEDEP}]
		dev-python/pycairo[${PYTHON_USEDEP}]
		dev-python/python-poppler[${PYTHON_USEDEP}] )
	dev-python/pillow[${PYTHON_USEDEP}]
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	dev-python/pygtk[${PYTHON_USEDEP}]
	sys-apps/coreutils"

PATCHES=( ${FILESDIR}/${PN}-0.6.1-doc-path.patch )
