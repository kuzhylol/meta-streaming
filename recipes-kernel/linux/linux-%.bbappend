FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:air = " file://openhd-sched.cfg"
SRC_URI:append:ground = " file://openhd-perf.cfg"
