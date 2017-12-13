# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit eutils gnome2-utils distutils-r1

DESCRIPTION="Metadata Anonymisation Toolkit"
HOMEPAGE="https://mat.boum.org/"
SRC_URI="https://mat.boum.org/files/${P}.tar.xz
	https://0xacab.org/mat/mat/raw/f775d4a61c0ab6c44e23a94a20820dd8e327de6f/data/mat.png -> ${P}_logo.png"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+audio +exif +pdf"

DEPEND="dev-python/python-distutils-extra[${PYTHON_USEDEP}]
	media-gfx/imagemagick[png]"
RDEPEND="${DEPEND}
	audio? ( media-libs/mutagen[${PYTHON_USEDEP}] )
	exif? ( media-libs/exiftool )
	pdf? ( dev-python/pdfrw[${PYTHON_USEDEP}]
		dev-python/pycairo[${PYTHON_USEDEP}]
		dev-python/python-poppler[${PYTHON_USEDEP}] )
	dev-python/pillow[${PYTHON_USEDEP}]
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	dev-python/pygtk[${PYTHON_USEDEP}]
	sys-apps/coreutils"

PATCHES=( "${FILESDIR}/Make_the_Nautilus_extension_work_again.patch"
	"${FILESDIR}/Avoid_spamming_the_logs.patch"
	"${FILESDIR}/Removed_System_category_from_desktop_entry_file.patch" )

src_prepare() {
	default

	convert "${DISTDIR}/${P}_logo.png" \
		-gravity center -background none -extent 3000x3000 \
		-resize 256 data/mat.png || die

	sed -i -e "s#share/doc/${PN}#share/doc/${PF}#g" setup.py || die
}

pkg_postinst() {
	gnome2_icon_cache_update

	elog "To get additional features, a number of optional runtime"
	elog "dependencies may be installed:"
	optfeature "nautilus menu integration" dev-python/nautilus-python
}

pkg_postrm() {
	gnome2_icon_cache_update
}
