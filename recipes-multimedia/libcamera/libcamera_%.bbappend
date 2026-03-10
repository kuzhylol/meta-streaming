FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://arducam-pivariety.json"

do_install:append() {
    install -d ${D}${datadir}/libcamera/ipa/rpi/vc4
    install -m 0644 ${WORKDIR}/arducam-pivariety.json ${D}${datadir}/libcamera/ipa/rpi/vc4/
}
