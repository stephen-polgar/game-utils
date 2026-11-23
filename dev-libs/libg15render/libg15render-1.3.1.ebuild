# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools

DESCRIPTION="Library for rendering text and graphics on Logitech G15 LCDs"
HOMEPAGE="https://github.com/vividnightmare/libg15render"
SRC_URI="https://github.com/vividnightmare/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="truetype"

RDEPEND="
	dev-libs/libg15
	truetype? ( media-libs/freetype:2 )
"
DEPEND="
	${RDEPEND}
	truetype? ( virtual/pkgconfig )
"
src_prepare() {
    default
    # version fix
    sed -i -e "s|^docdir = .*|docdir = \$(prefix)/share/doc/${PF}|" Makefile.am Makefile.in || die
    chmod +x "${S}/configure" || die
}

src_configure() {
	local myeconfargs=(
		--disable-static
	)

	if use truetype; then
		myeconfargs+=( --enable-ttf )
	else
		myeconfargs+=( --disable-ttf )
	fi

	econf "${myeconfargs[@]}"
}

src_install() {
	default

	# Do not install libtool archive files.
	find "${ED}" -type f -name '*.la' -delete || die
}
