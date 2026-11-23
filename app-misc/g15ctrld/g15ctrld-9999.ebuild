# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 toolchain-funcs udev

DESCRIPTION="Alternative daemon for Logitech G15/G510 gaming keyboards"
HOMEPAGE="https://gitlab.com/raycollector/g15ctrld"

EGIT_REPO_URI="https://gitlab.com/raycollector/g15ctrld.git"
EGIT_BRANCH="main"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="dbus"

DEPEND="
    dev-libs/hidapi
    dev-libs/libevdev
    net-misc/curl
    virtual/libudev
    x11-libs/libxkbcommon
    =app-misc/lcdproc-0.5.9_p20211220-r1[lcd_devices_g15]
    =dev-libs/libg15-1.3.1
    =dev-libs/libg15render-1.3.1
"
RDEPEND="
    ${DEPEND}
    x11-misc/ydotool
"
DOCS=( README.md )

src_compile() {
    emake \
        CC="$(tc-getCXX)" \
        CFLAGS="${CXXFLAGS} -Iinclude -MMD -MP -pthread" \
        LDFLAGS="${LDFLAGS} -lcurl -lhidapi-hidraw -lhidapi-libusb -levdev -ludev -lxkbcommon -pthread"
}

src_install() {
    dobin bin/g15ctrld

    newinitd "${FILESDIR}/g15ctrld.initd" g15ctrld
    systemd_dounit "${FILESDIR}/lcdexec.service"
    insinto /lib/udev/rules.d
    doins "${FILESDIR}/70-g15ctrld.rules"
    insinto /etc
    doins "${S}/LCDd.conf"
    sed -i -e "s|^DriverPath=.*|DriverPath=/usr/$(get_libdir)/lcdproc/|" "${ED}/etc/LCDd.conf" || die

    if use dbus; then
      insinto /lib/udev/rules.d
      doins "${FILESDIR}/70-g15-autorun.rules"
      exeinto /usr/libexec/g15ctrld
      doexe "${FILESDIR}/g15-event.sh"
      newinitd "${FILESDIR}/g15-autorun.initd" g15-autorun
      systemd_dounit "${FILESDIR}/g15-autorun.service"
    fi

    keepdir /var/lib/g15ctrld
    fperms 0755 /var/lib/g15ctrld
    einstalldocs
}

pkg_postinst() {
    udev_reload

    elog  "Change drivers in /etc/LCDd.conf file like:"
    elog  "driver=g15"
    elog  "driver=linux_input"
    elog  "or update /etc/LCDd.conf."
    elog  "If use dbus enabled then do"
    elog  "systemctl enable g15-autorun or rc-update add g15-autorun default"
    elog  "else read /usr/share/doc/g15ctrld-9999/README.md.bz2"
}

pkg_postrm() {
    udev_reload
}
