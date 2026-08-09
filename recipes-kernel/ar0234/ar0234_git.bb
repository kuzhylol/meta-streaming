# Recipe created by recipetool
# This is the basis of a recipe and may need further editing in order to be fully functional.
# (Feel free to remove these comments when editing.)

# WARNING: the following LICENSE and LIC_FILES_CHKSUM values are best guesses - it is
# your responsibility to verify that the values are complete and correct.
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=b234ee4d69f5fce4486a80fdaf4a4263"

SRC_URI = "git://github.com/kuzhylol/ar0234-v4l2-driver;protocol=https;branch=main"

# Modify these as desired
PV = "1.0+git"
SRCREV = "06343cf4208a9de5ee8c3effbb35e228a315a70a"

inherit module

EXTRA_OEMAKE:append:task-install = " -C ${STAGING_KERNEL_DIR} M=${S}"
EXTRA_OEMAKE += "KDIR=${STAGING_KERNEL_DIR}"

DEPENDS += "dtc-native"

do_compile:append() {
    dtc -@ -I dts -O dtb -o ${B}/ar0234.dtbo ${S}/ar0234-overlay.dts
}

do_install:append() {
    install -d ${D}/boot/overlays
    install -m 0644 ${B}/ar0234.dtbo ${D}/boot/overlays/
}

FILES:${PN} += "/boot/overlays/ar0234.dtbo"
