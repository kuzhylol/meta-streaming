SRCREV = "eb3ee430dd1c96a9415c4be3657d8f0e976f8102"
SRC_URI[sha256sum] = "379fc491e7e555c0545bbc4e9b40f543334d84a5ab4392bc97f6762b5979381c"

do_install:append() {
    install -d ${D}${datadir}/boot/overlays/

    install -m 0644 ${S}/overlays/arducam-pivariety.dtbo ${D}${datadir}/boot/overlays/
}
