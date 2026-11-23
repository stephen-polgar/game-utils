# Copyright 2026
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools

DESCRIPTION="Library for low-level access to Logitech G-series keyboards"
HOMEPAGE="https://github.com/vividnightmare/libg15"
SRC_URI="https://github.com/vividnightmare/libg15/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

# This release still uses the libusb-0.1 API (usb.h / -lusb).
RDEPEND="dev-libs/libusb-compat"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${P}"

src_prepare() {
    default
    chmod +x "${S}/configure" || die
}

src_configure() {
	econf --disable-static
}

src_install() {
	default

	# Do not install libtool archives.
	find "${ED}" -type f -name '*.la' -delete || die
}
