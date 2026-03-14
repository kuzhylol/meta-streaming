FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://arducam-pivariety.json"

DEPENDS += "arducam-pivariety-sdk"
PACKAGECONFIG:append:raspberrypi4-64 = " gst pycamera raspberrypi"

do_install:append() {
    install -d ${D}${datadir}/libcamera/ipa/rpi/vc4
    install -m 0644 ${UNPACKDIR}/arducam-pivariety.json ${D}${datadir}/libcamera/ipa/rpi/vc4/
}
