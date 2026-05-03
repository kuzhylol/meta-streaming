FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://openhd-air.service \
            file://openhd-ground.service \
            file://ARDUCAM_0.json \
            file://air_camera_generic.json \
            file://air_settings.json \
            "

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

    install -d ${D}/usr/local/share/openhd/telemetry
    install -m 0644 ${UNPACKDIR}/air_settings.json ${D}${systemd_unitdir}/usr/local/share/openhd/telemetry
}

do_install:append:ground() {
    install -m 0644 ${UNPACKDIR}/openhd-ground.service ${D}${systemd_unitdir}/system/openhd.service
}

PACKAGECONFIG ??= ""
PACKAGECONFIG[debug] = ""

DEBUG_FLAGS = "-O0 -g -feliminate-unused-debug-types"

CFLAGS:append = "${@bb.utils.contains('PACKAGECONFIG', 'debug', ' ${DEBUG_FLAGS}', '', d)}"
CXXFLAGS:append = "${@bb.utils.contains('PACKAGECONFIG', 'debug', ' ${DEBUG_FLAGS}', '', d)}"

INHIBIT_PACKAGE_STRIP = "${@bb.utils.contains('PACKAGECONFIG', 'debug', '1', '0', d)}"
INHIBIT_SYSROOT_STRIP = "${@bb.utils.contains('PACKAGECONFIG', 'debug', '1', '0', d)}"

EXTRA_OECMAKE:append = "${@bb.utils.contains('PACKAGECONFIG', 'debug', ' -DCMAKE_BUILD_TYPE=Debug', '', d)}"

FILES:${PN} += "/usr/local/share/openhd/video/ARDUCAM_0.json \
                /usr/local/share/openhd/video/air_camera_generic.json \
                /usr/local/share/openhd/telemetry/air_settings.json \
                "
