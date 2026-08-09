SUMMARY = "Arducam Pivariety SDK"
DESCRIPTION = "Prebuilt Arducam Pivariety SDK libraries and headers"
LICENSE = "CLOSED"

SRC_URI = "git://github.com/ArduCAM/arducam_ppa.git;protocol=https;branch=master"
SRCREV = "${AUTOREV}"

DEPENDS += "binutils-native"

RDEPENDS:${PN} += "zlib"

DEB_NAME:aarch64 = "arducam-pivariety-sdk-dev_1.0.7_arm64.deb"
DEB_NAME:arm = "arducam-pivariety-sdk-dev_1.0.7_armhf.deb"

DEB_PATH = "${S}/pool/main/a/arducam-pivariety-sdk-dev/${DEB_NAME}"

do_install() {
    rm -rf ${WORKDIR}/deb
    rm -rf ${WORKDIR}/pkg_ext

    mkdir -p ${WORKDIR}/deb
    mkdir -p ${WORKDIR}/pkg_ext

    cp ${DEB_PATH} ${WORKDIR}/deb/

    cd ${WORKDIR}/deb

    ar x *.deb

    DATA=$(echo data.tar.*)

    case "$DATA" in
        *.xz)
            tar --no-same-owner -xJf "$DATA" -C ${WORKDIR}/pkg_ext
            ;;
        *.gz)
            tar --no-same-owner -xzf "$DATA" -C ${WORKDIR}/pkg_ext
            ;;
        *.zst)
            tar --no-same-owner --zstd -xf "$DATA" -C ${WORKDIR}/pkg_ext
            ;;
        *)
            bbfatal "Unsupported archive format: $DATA"
            ;;
    esac

    install -d ${D}${libdir}
    install -d ${D}${includedir}
    install -d ${D}${libdir}/pkgconfig

    if [ -d ${WORKDIR}/pkg_ext/usr/lib ]; then
        cp -r --no-preserve=ownership \
            ${WORKDIR}/pkg_ext/usr/lib/. \
            ${D}${libdir}/
    fi

    if [ -d ${WORKDIR}/pkg_ext/usr/include ]; then
        cp -r --no-preserve=ownership \
            ${WORKDIR}/pkg_ext/usr/include/. \
            ${D}${includedir}/
    fi

    # Ensure everything appears as root-owned to pseudo
    chown -R root:root ${D}
}

FILES:${PN} += "\
    ${libdir}/*.so \
    ${libdir}/*.so.* \
"

FILES:${PN}-dev += "\
    ${includedir} \
    ${libdir}/pkgconfig \
"

INSANE_SKIP:${PN} += "already-stripped ldflags dev-so"

SOLIBS = ".so"
FILES_SOLIBSDEV = ""
