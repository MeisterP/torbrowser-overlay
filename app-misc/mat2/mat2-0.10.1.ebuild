# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )
DISTUTILS_SINGLE_IMPL=1

inherit desktop distutils-r1 xdg

DESCRIPTION="Metadata Anonymisation Toolkit"
HOMEPAGE="https://0xacab.org/jvoisin/mat2"
SRC_URI="https://0xacab.org/jvoisin/mat2/-/archive/${PV}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+audio +image +pdf +svg +video nautilus +sandbox"

DEPEND="${PYTHON_DEPS}"
RDEPEND="${DEPEND}
	$(python_gen_cond_dep '
		audio? ( media-libs/mutagen[${PYTHON_MULTI_USEDEP}] )
		dev-python/pygobject[${PYTHON_MULTI_USEDEP}]
		nautilus? ( dev-python/nautilus-python[${PYTHON_SINGLE_USEDEP}] )
		pdf? ( dev-python/pycairo[${PYTHON_MULTI_USEDEP}]
			app-text/poppler[cairo,introspection] )
	')
	image? ( x11-libs/gdk-pixbuf[jpeg,tiff,introspection] )
	media-libs/exiftool
	sandbox? ( sys-apps/bubblewrap )
	svg? ( gnome-base/librsvg[introspection] )
	video? ( virtual/ffmpeg )"

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

	insinto /usr/share/kservices5/ServiceMenus/
	doins dolphin/mat2.desktop
}
