# Copyright 2018-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
PYTHON_REQ_USE="xml(+)"
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 optfeature

DESCRIPTION="Metadata Anonymisation Toolkit"
HOMEPAGE="https://github.com/jvoisin/mat2"
SRC_URI="https://github.com/jvoisin/mat2/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	app-text/poppler[introspection,cairo]
	dev-libs/glib:2
	dev-python/pycairo:0[${PYTHON_USEDEP}]
	dev-python/pygobject:3[cairo,${PYTHON_USEDEP}]
	gnome-base/librsvg[introspection]
	media-libs/mutagen:0[${PYTHON_USEDEP}]
	x11-libs/gdk-pixbuf:2[introspection,jpeg,tiff]
"
BDEPEND="
	test? (
		gui-libs/gdk-pixbuf-loader-webp
		media-libs/exiftool:*
		media-video/ffmpeg[lame,vorbis]
		x11-libs/gdk-pixbuf:2[introspection,jpeg,tiff]
	)
"

DOCS=( doc {CHANGELOG,CONTRIBUTING,INSTALL,README}.md )

distutils_enable_tests unittest

PATCHES=(
	"${FILESDIR}"/mat2-0.14.0-fix-tests.patch
)

pkg_postinst() {
	optfeature "misc file format support" media-libs/exiftool
	optfeature "video support" media-video/ffmpeg
}
