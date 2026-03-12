LICENSE = "BSD-2-Clause & GPL-2.0-only & GPL-2.0-or-later"
LIC_FILES_CHKSUM = "file://LICENSE;md5=3417a46e992fdf62e5759fba9baef7a7 \
                    file://LICENSES/GPL-2.0-only.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
                    file://LICENSES/GPL-2.0-or-later.txt;md5=fed54355545ffd980b814dab4a3b312c"

SRC_URI = "git://github.com/raspberrypi/libpisp;protocol=https;branch=main"

PV = "1.0+git"
SRCREV = "15e11061b9e856f94d6fcd8b09dea79b88b4d953"

S = "${WORKDIR}/git"

inherit pkgconfig meson

DEPENDS += "nlohmann-json"

do_install:append() {
    chrpath -d ${D}${libdir}/libpisp.so.1.3.0 || true
}

FILES:${PN} += " \
    ${datadir}/libpisp/backend_default_config.json \
    ${libdir}/libpisp.so.* \
"

FILES:${PN}-dev += " \
    ${includedir} \
"
INSANE_SKIP:${PN} += "buildpaths"
