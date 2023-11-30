# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..12} )

inherit distutils-r1

DESCRIPTION="Metadata Anonymisation Toolkit"
HOMEPAGE="https://0xacab.org/jvoisin/mat2"
SRC_URI="https://0xacab.org/jvoisin/mat2/-/archive/${PV}/${P}.tar.bz2"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+exif sandbox video"
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	test? ( exif video !sandbox )
"

RDEPEND="
	${PYTHON_DEPS}
	app-text/poppler[introspection]
	dev-python/pycairo:0[${PYTHON_USEDEP}]
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	gnome-base/librsvg:2[introspection]
	media-libs/mutagen:0[${PYTHON_USEDEP}]
	x11-libs/gdk-pixbuf:2[introspection]
	exif? ( media-libs/exiftool:* )
	sandbox? ( sys-apps/bubblewrap )
	video? ( media-video/ffmpeg:* )
"
DEPEND="
	${RDEPEND}
	test? (
		media-video/ffmpeg[mp3,vorbis]
		x11-libs/gdk-pixbuf:2[jpeg,tiff]
		dev-python/unittest-or-fail
	)
"
src_prepare() {
	default

	# ValueError: invalid pyproject.toml config: `project`
	rm pyproject.toml || die

	# installed manually
	sed -i -e "/data_files.*/d" setup.py || die
}

src_install() {
	distutils-r1_src_install

	dodoc CHANGELOG.md CONTRIBUTING.md README.md
	dodoc doc/comparison_to_others.md doc/implementation_notes.md doc/threat_model.md
	doman doc/mat2.1
}

distutils_enable_tests unittest
