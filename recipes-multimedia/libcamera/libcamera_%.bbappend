FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://arducam-pivariety.json \
            file://99-dmaheap.rules \
           "

DEPENDS += "arducam-pivariety-sdk"
PACKAGECONFIG:append:rpi = " gst pycamera raspberrypi"
RDEPENDS:${PN} += "${PN}-gst ${PN}-pycamera"

CXXFLAGS:append = " -Wno-error=maybe-uninitialized"

do_install:append() {
    install -d ${D}${datadir}/libcamera/ipa/rpi/vc4/
    install -m 0644 ${UNPACKDIR}/arducam-pivariety.json ${D}${datadir}/libcamera/ipa/rpi/vc4/

    install -d ${D}${sysconfdir}/udev/rules.d/
    install -m 0644 ${UNPACKDIR}/99-dmaheap.rules ${D}${sysconfdir}/udev/rules.d/99-dmaheap.rules
}
