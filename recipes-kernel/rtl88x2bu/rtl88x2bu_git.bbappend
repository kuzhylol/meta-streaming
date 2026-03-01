FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://rtl88x2bu.conf"

do_install:append() {
    install -d ${D}${sysconfdir}/modprobe.d
    install -m 0644 ${UNPACKDIR}/rtl88x2bu.conf ${D}${sysconfdir}/modprobe.d/rtl88x2bu.conf
}

FILES:${PN} += "${sysconfdir}/modprobe.d/rtl88x2bu.conf"
