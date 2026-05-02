FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://QOpenHD.conf"

do_install:append() {
    install -d ${D}${sysconfdir}/OpenHD

    install -m 0644 ${WORKDIR}/QOpenHD.conf \
        ${D}${sysconfdir}/OpenHD/QOpenHD.conf
}

FILES:${PN} += "${sysconfdir}/OpenHD/QOpenHD.conf"
