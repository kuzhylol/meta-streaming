SUMMARY = "Arducam Pivariety SDK for AArch64 and ARMhf"
LICENSE = "CLOSED"

SRC_URI = "git://github.com/ArduCAM/arducam_ppa.git;protocol=https;branch=master"
SRCREV = "${AUTOREV}"

# The git checkout goes into ${S}
S = "${WORKDIR}/git"

DEPENDS += "dpkg-native"
RDEPENDS:${PN} += "zlib"

DEB_NAME:aarch64 = "arducam-pivariety-sdk-dev_1.0.7_arm64.deb"
DEB_NAME:arm = "arducam-pivariety-sdk-dev_1.0.7_armhf.deb"

DEB_PATH = "${S}/pool/main/a/arducam-pivariety-sdk-dev/${DEB_NAME}"

do_install() {
    install -d ${D}${libdir}
    install -d ${D}${includedir}

    bbnote "Unpacking Arducam SDK: ${DEB_PATH}"
    ${STAGING_BINDIR_NATIVE}/dpkg-deb -x ${DEB_PATH} ${WORKDIR}/pkg_ext

    if [ -d ${WORKDIR}/pkg_ext/usr/lib ]; then
        cp -dr ${WORKDIR}/pkg_ext/usr/lib/* ${D}${libdir}/
    fi

    if [ -d ${WORKDIR}/pkg_ext/usr/include ]; then
        cp -r ${WORKDIR}/pkg_ext/usr/include/* ${D}${includedir}/
    fi
}

INSANE_SKIP:${PN} += "ldflags already-stripped dev-so"

FILES:${PN} += "${libdir}/*.so*"
FILES:${PN}-dev += "${includedir}/*"

SOLIBS = ".so"
FILES_SOLIBSDEV = ""
