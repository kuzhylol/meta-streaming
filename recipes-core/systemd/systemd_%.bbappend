FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://99-openhd-max-socket.conf"

do_install:append() {
    install -d ${D}${sysconfdir}/sysctl.d
    install -m 0644 ${UNPACKDIR}/99-openhd-max-socket.conf ${D}${sysconfdir}/sysctl.d/
}

FILES:${PN} += "${sysconfdir}/sysctl.d/99-openhd-max-socket.conf"
