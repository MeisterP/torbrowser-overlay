# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{5,6,7} )
DISTUTILS_SINGLE_IMPL=1

inherit desktop xdg-utils distutils-r1

DESCRIPTION="Metadata Anonymisation Toolkit"
HOMEPAGE="https://0xacab.org/jvoisin/mat2"
SRC_URI="https://0xacab.org/jvoisin/mat2/-/archive/${PV}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+audio +image +pdf +video nautilus +sandbox"

DEPEND="${PYTHON_DEPS}"
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
	"${EPYTHON}" -m unittest discover -v || die "Tests fail with ${EPYTHON}"
	if has usersandbox $FEATURES ; then
		einfo "The following LD_PRELOAD errors can be ignored:"
		einfo "ERROR: ld.so: object 'libsandbox.so' from LD_PRELOAD cannot be preloaded (cannot open shared object file): ignored."
		einfo "see https://wiki.gentoo.org/wiki/Knowledge_Base:Object_libsandbox.so_from_LD_PRELOAD_cannot_be_preloaded"
	fi
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
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
