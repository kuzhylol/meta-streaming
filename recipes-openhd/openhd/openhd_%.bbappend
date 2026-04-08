FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://openhd-air.service \
            file://openhd-ground.service \
            file://ARDUCAM_0.json \
            file://air_camera_generic.json"

SRC_URI:mc:ground-rpi4 += "file://0001-Add-AR0234-support.patch"

DEPENDS += "libcamera libusb1"

do_install:append() {
    install -d ${D}${systemd_unitdir}/system
}

do_install:append:air() {
    install -d ${D}/usr/local/share/openhd/video
    install -m 0644 ${UNPACKDIR}/ARDUCAM_0.json ${D}/usr/local/share/openhd/video
    install -m 0644 ${UNPACKDIR}/air_camera_generic.json ${D}/usr/local/share/openhd/video
    rm -f ${D}/usr/local/share/openhd/video/MMAL_HDMI_0.json

    install -m 0644 ${UNPACKDIR}/openhd-air.service ${D}${systemd_unitdir}/system/openhd.service
}

do_install:append:ground() {
    install -m 0644 ${UNPACKDIR}/openhd-ground.service ${D}${systemd_unitdir}/system/openhd.service
}

FILES:${PN} += "/usr/local/share/openhd/video/ARDUCAM_0.json /usr/local/share/openhd/video/air_camera_generic.json"
