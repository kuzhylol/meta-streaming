FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://QOpenHD.conf"

do_install:append() {
    install -d ${D}${ROOT_HOME}/.config/OpenHD
    install -m 0644 ${UNPACKDIR}/QOpenHD.conf \
        ${D}${ROOT_HOME}/.config/OpenHD/QOpenHD.conf
}

FILES:${PN} += "${ROOT_HOME}/.config/OpenHD/QOpenHD.conf"
