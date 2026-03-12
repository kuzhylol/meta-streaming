FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://openhd.service \
            file://0001-Add-AR0234-support.patch \
            "

DEPENDS += "libcamera libusb1"

do_install:append() {
    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${UNPACKDIR}/openhd.service ${D}${systemd_unitdir}/system/openhd.service
}

SYSTEMD_AUTO_ENABLE:${PN} = "enable"
