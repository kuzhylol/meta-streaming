#!/usr/bin/env bash
# Build a meta-streaming multiconfig image in the streaming-yocto container.
# Usage: ./build-streaming.sh [multiconfig]   (default: air-rpi4)
set -euo pipefail

# This script lives in meta-streaming/conf/templates/streaming/; the workspace
# root (Docker build context, bind-mounted as /workspace) is four levels up.
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR="$(cd "${HERE}/../../../.." && pwd)"
MC="${1:-air-rpi4}"

docker build -t streaming-yocto \
    --build-arg USER_ID="$(id -u)" --build-arg GROUP_ID="$(id -g)" \
    -f "${HERE}/Dockerfile.streaming" "${DIR}"

docker run --rm -i -v "${DIR}:/workspace" -e MC="${MC}" streaming-yocto \
    /bin/bash <<'INNER'
set -eo pipefail
cd /workspace

# OE-Core bundles neither bitbake nor poky; fetch bitbake (branch matches
# BB_MIN_VERSION) and write our own conf for the OE-Core layout.
[ -d bitbake ] || git clone --branch 2.18 --single-branch \
    https://git.openembedded.org/bitbake bitbake
source openembedded-core/oe-init-build-env build >/dev/null

rm -f build/bitbake.sock build/bitbake.lock build/hashserve.sock
mkdir -p build/conf

cat > build/conf/bblayers.conf <<'BBLAYERS'
POKY_BBLAYERS_CONF_VERSION = "2"
BBPATH = "${TOPDIR}"
BBFILES ?= ""
BBLAYERS ?= " \
  /workspace/openembedded-core/meta \
  /workspace/meta-openembedded/meta-oe \
  /workspace/meta-openembedded/meta-python \
  /workspace/meta-openembedded/meta-networking \
  /workspace/meta-raspberrypi \
  /workspace/meta-openhd \
  /workspace/meta-streaming \
  /workspace/meta-qt5 \
  "
BBLAYERS

if ! grep -q '^BBMULTICONFIG' build/conf/local.conf 2>/dev/null; then
    cp meta-streaming/conf/templates/streaming/local.conf.sample build/conf/local.conf
    echo 'DISTRO = ""' >> build/conf/local.conf  # poky.conf absent in OE-Core
fi

exec bitbake "mc:${MC}:core-image-minimal"
INNER
