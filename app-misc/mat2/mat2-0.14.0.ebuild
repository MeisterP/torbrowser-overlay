# Copyright 2018-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..14} )
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
		media-libs/exiftool:*
		media-video/ffmpeg[lame,vorbis]
		x11-libs/gdk-pixbuf:2[introspection,jpeg,tiff]
	)
"

DOCS=( doc {CHANGELOG,CONTRIBUTING,INSTALL,README}.md )

distutils_enable_tests unittest

src_test() {
	# Double sandboxing is not possible
	if ! has usersandbox ${FEATURES}; then
		distutils-r1_src_test
	fi
	return 0
}

pkg_postinst() {
	optfeature "misc file format support" media-libs/exiftool
	optfeature "video support" media-video/ffmpeg
}
