SUMMARY = "Arducam Pivariety SDK for AArch64"
LICENSE = "CLOSED"

# Point to your local .deb file
SRC_URI = "file://arducam-pivariety-sdk-dev_1.0.7_arm64.deb;unpack=0"

# Tell Yocto NOT to try and unpack it automatically (we will do it manually)
#SRC_URI[unpack] = "0"

# We need dpkg-native to unpack the .deb on the build host
DEPENDS += "dpkg-native"
RDEPENDS:${PN} += "zlib"

do_install() {
    # 1. Create the destination directories
    install -d ${D}${libdir}
    install -d ${D}${includedir}

    # 2. Find the .deb (Bitbake might put it in ${WORKDIR} or ${WORKDIR}/files)
    # Using a wildcard or checking the local directory:
    DEB_FILE="${UNPACKDIR}/arducam-pivariety-sdk-dev_1.0.7_arm64.deb"

    # If the above fails, Yocto might have put it in a subdir. Let's extract it:
    ${STAGING_BINDIR_NATIVE}/dpkg-deb -x $DEB_FILE ${WORKDIR}/pkg_ext

    # 3. Copy the files
    cp -r ${WORKDIR}/pkg_ext/usr/lib/* ${D}${libdir}/
    cp -r ${WORKDIR}/pkg_ext/usr/include/* ${D}${includedir}/
}

# Tell Yocto to skip sanity checks that usually fail with pre-compiled binaries
INSANE_SKIP:${PN} += "ldflags already-stripped dev-so"
FILES:${PN} += "${libdir}/*.so*"
FILES:${PN}-dev += "${includedir}/*"
