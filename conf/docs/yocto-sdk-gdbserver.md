# Yocto SDK + Remote Debugging Guide (End-to-End)

This document walks through a complete workflow for building, deploying, and debugging applications using a Yocto SDK, including remote debugging on a Raspberry Pi and a proxy setup.

---

# 1. Generate (Populate) Yocto SDK

Build your image first:

```bash
bitbake mc-image
```

Then generate the SDK:

### Standard SDK

```bash
bitbake mc-image -c populate_sdk
```

### Extensible SDK (recommended)

```bash
bitbake mc-image -c populate_sdk_ext
```

Output:

```
tmp/deploy/sdk/
```

---

# 2. Install and Source Yocto SDK

Install:

```bash
./poky-*-mc-image-*.sh
```

Example install path:

```
/opt/mc-sdk
```

Source environment:

```bash
source /opt/mc-sdk/environment-setup-*
```

Verify:

```bash
echo $CC
echo $SDKTARGETSYSROOT
```

---

# 3. Enable Debug Packages

Add to your config:

```bitbake
EXTRA_IMAGE_FEATURES += "dbg-pkgs"
```

Or per package:

```bitbake
IMAGE_INSTALL += "your-app-dbg"
```

---

# 4. Example `.bbappend` with Debug PACKAGECONFIG

```bitbake
# recipes-foo/your-app/your-app.bbappend

PACKAGECONFIG ??= ""

PACKAGECONFIG[debug] = ",,,"

CFLAGS:append:pn-your-app:debug = " -Og -g"
CXXFLAGS:append:pn-your-app:debug = " -Og -g"

INHIBIT_PACKAGE_STRIP:pn-your-app:debug = "1"
INHIBIT_SYSROOT_STRIP:pn-your-app:debug = "1"

EXTRA_OECMAKE:append:pn-your-app:debug = " -DCMAKE_BUILD_TYPE=Debug"
```

Enable it:

```bitbake
PACKAGECONFIG:append:pn-your-app = " debug"
```

---

# 5. Start HTTP Server for Packages

In deploy directory:

```bash
start-stop-daemon --start --background --make-pidfile --pidfile /tmp/yocto-http.pid \
  --chdir tmp/deploy/deb \
  --exec /usr/bin/python3 -- -m http.server 8000
```

Now packages are available at:

```
http://<host-ip>:8000
```

---

# 6. Install Debug Packages via APT on Target

On Raspberry Pi:

### Add repo

```bash
echo "deb [trusted=yes] http://<host-ip>:8000 ./" > /etc/apt/sources.list.d/yocto.list
apt update
```

### Install

```bash
apt install your-app-dbg
```

---

# 7. Visual Studio Code Setup

## Required Extensions

* C/C++
* CMake Tools (if applicable)
* Remote - SSH

---

## Example `launch.json`

```json
{
  "name": "Yocto Remote Debug",
  "type": "cppdbg",
  "request": "launch",
  "program": "${workspaceFolder}/your-app",
  "miDebuggerServerAddress": "192.168.1.10:2345",
  "miDebuggerPath": "${env:GDB}",
  "setupCommands": [
    {
      "text": "set sysroot ${env:SDKTARGETSYSROOT}"
    }
  ]
}
```

---

# 8. Run Debug App on Raspberry Pi

### On target:

```bash
gdbserver :2345 ./your-app
```

### On host:

```bash
source /opt/mc-sdk/environment-setup-*
$GDB your-app
```

Then in GDB:

```gdb
set sysroot $SDKTARGETSYSROOT
target remote 192.168.1.10:2345
```

---

# 9. Proxy Setup (Ubuntu → Raspberry Pi → Mac)

## SSH Proxy (recommended)

On Mac (`~/.ssh/config`):

```bash
Host rpi
    HostName raspberrypi
    User pi
    ProxyJump ubuntu_user@ubuntu_host
```

Connect:

```bash
ssh rpi
```

---

## Port Forwarding for Debugging

From Mac:

```bash
ssh -L 2345:localhost:2345 ubuntu_user@ubuntu_host
```

Then on Ubuntu:

```bash
ssh -L 2345:localhost:2345 pi@raspberrypi
```

Now Mac can connect:

```gdb
target remote localhost:2345
```

---

# 10. Full Debug Flow Summary

```text
Mac (VS Code + SDK GDB)
   ↓ (SSH / Proxy)
Ubuntu (jump host)
   ↓
Raspberry Pi (gdbserver running app)
```

---

# Key Best Practices

* Use `-Og -g` instead of `-O0` for better debugging
* Keep symbols in SDK instead of target when possible
* Always `set sysroot`
* Use `PACKAGECONFIG` for selective debug builds
* Avoid enabling debug globally unless necessary

---

# Minimal Working Debug Sequence

```bash
# Target
gdbserver :2345 ./your-app

# Host
source environment-setup-*
$GDB your-app
(gdb) set sysroot $SDKTARGETSYSROOT
(gdb) target remote <ip>:2345
```

---

This setup gives you a reproducible, scalable debugging workflow across Yocto builds, remote targets, and multi-hop network environments.

