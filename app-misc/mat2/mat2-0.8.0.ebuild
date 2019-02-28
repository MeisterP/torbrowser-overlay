# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{5,6} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 gnome2-utils

DESCRIPTION="Metadata Anonymisation Toolkit"
HOMEPAGE="https://0xacab.org/jvoisin/mat2"
SRC_URI="https://0xacab.org/jvoisin/mat2/-/archive/${PV}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+audio +image +pdf +video nautilus +sandbox"

DEPEND="dev-python/python-distutils-extra[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}
	audio? ( media-libs/mutagen[${PYTHON_USEDEP}] )
	image? ( x11-libs/gdk-pixbuf[jpeg,tiff,introspection] )
	pdf? ( dev-python/pycairo[${PYTHON_USEDEP}]
		app-text/poppler[cairo,introspection] )
	video? ( virtual/ffmpeg )

	nautilus? ( dev-python/nautilus-python[${PYTHON_USEDEP}] )
	sandbox? ( sys-apps/bubblewrap )

	dev-python/pygobject[${PYTHON_USEDEP}]
	media-libs/exiftool"

DOCS=( README.md doc/implementation_notes.md doc/threat_model.md )

python_test() {
	if has usersandbox $FEATURES ; then
		ewarn "Test suite is known to fail with FEATURES=usersandbox -- skipping ..."
		#ERROR: ld.so: object 'libsandbox.so' from LD_PRELOAD cannot be preloaded"
		return 0
	fi
	"${EPYTHON}" -m unittest discover -v || die "Tests fail with ${EPYTHON}"
}

python_install_all() {
	distutils-r1_python_install_all

	doman doc/mat2.1
	doicon -s 512 data/mat2.png
	doicon -s scalable data/mat2.svg

	insinto /usr/share/nautilus-python/extensions/
	doins nautilus/mat2.py
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
