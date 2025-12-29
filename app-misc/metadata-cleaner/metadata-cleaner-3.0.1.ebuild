# Copyright 2021-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{11..14} )

inherit gnome2-utils meson python-single-r1

DESCRIPTION="Python GTK application to view and clean metadata in files, using mat2."
HOMEPAGE="https://gitlab.com/metadatacleaner/metadatacleaner"
SRC_URI="https://gitlab.com/metadatacleaner/metadatacleaner/-/archive/v${PV}/metadatacleaner-v${PV}.tar.bz2"
S=${WORKDIR}/metadatacleaner-v${PV}

LICENSE="GPL-3+ CC-BY-SA-4.0"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="${PYTHON_DEPS}
	dev-util/itstool
	gui-libs/gtk:4
	gui-libs/libadwaita
	$(python_gen_cond_dep '
		dev-python/pygobject[${PYTHON_USEDEP}]
		app-misc/mat2[${PYTHON_USEDEP}]
	')"

RDEPEND="${DEPEND}"

src_configure() {
	python_setup
	meson_src_configure
}

src_install() {
	meson_src_install
	python_optimize
}

pkg_postinst() {
	gnome2_schemas_update
	xdg_desktop_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	gnome2_schemas_update
	xdg_desktop_database_update
	xdg_icon_cache_update
}
