SUMMARY = "Device Tree Overlay for Hynitron CST816X Touchscreen"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://hynitron-cst816s.dts"

S = "${UNPACKDIR}"

DEPENDS += "dtc-native"

COMPATIBLE_MACHINE = "raspberrypi4-64"

do_compile() {
    dtc -@ -I dts -O dtb -o ${B}/hynitron-cst816s.dtbo ${S}/hynitron-cst816s.dts
}

do_install() {
    install -d ${D}/boot/overlays
    install -m 0644 ${B}/hynitron-cst816s.dtbo ${D}/boot/overlays/
}

FILES:${PN} += "/boot/overlays/hynitron-cst816s.dtbo"
