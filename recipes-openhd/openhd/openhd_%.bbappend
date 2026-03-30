FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://openhd-air.service \
            file://openhd-ground.service"

SRC_URI:mc:ground-rpi4 += "file://0001-Add-AR0234-support.patch"

DEPENDS += "libcamera libusb1"

do_install:append() {
    install -d ${D}${systemd_unitdir}/system
}

do_install:append:mc:air-rpi0() {
    install -m 0644 ${UNPACKDIR}/openhd-air.service ${D}${systemd_unitdir}/system/openhd.service
}

do_install:append:mc:air-rpi4() {
    install -m 0644 ${UNPACKDIR}/openhd-air.service ${D}${systemd_unitdir}/system/openhd.service
}

do_install:append:mc:ground-rpi4() {
    install -m 0644 ${UNPACKDIR}/openhd-ground.service ${D}${systemd_unitdir}/system/openhd.service
}

SYSTEMD_AUTO_ENABLE:${PN} = "enable"
