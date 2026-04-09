FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://rtl8812au.conf"

do_install:append:raspberrypi4-64() {
    install -d ${D}${sysconfdir}/modprobe.d
    install -m 0644 ${UNPACKDIR}/rtl8812au.conf ${D}${sysconfdir}/modprobe.d/rtl8812au.conf
}

FILES:${PN} += "${sysconfdir}/modprobe.d/rtl8812au.conf"
