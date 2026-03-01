FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://blacklist-rtw88.conf"

do_install:append() {
    install -d ${D}${sysconfdir}/modprobe.d
    install -m 0644 ${UNPACKDIR}/blacklist-rtw88.conf \
        ${D}${sysconfdir}/modprobe.d/blacklist-rtw88.conf
}

FILES:${PN} += "${sysconfdir}/modprobe.d/blacklist-rtw88.conf"
