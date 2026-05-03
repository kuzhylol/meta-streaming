# Architecture

VS Code UI Mac
C++ extension	Ubuntu (remote): 192.168.1.102
GDB	Ubuntu (SDK): 192.168.1.102
gdbserver	Raspberry Pi: 192.168.1.137


# Yocto SDK + Remote Debugging Guide (End-to-End)

This document walks through a complete workflow for building, deploying, and debugging applications using a Yocto SDK, including remote debugging on a Raspberry Pi and a proxy setup.

---

# 1. Generate (Populate) Yocto SDK

Add gdb to target and host SDK (local.conf)

```bash
IMAGE_INSTALL:append = " gdbserver"
EXTRA_IMAGE_FEATURES += "dbg-pkgs"
TOOLCHAIN_HOST_TASK:append = " nativesdk-packagegroup-sdk-host"
```

Build your image:

```bash
bitbake mc-image
```

Then generate the SDK:

### Standard SDK

```bash
bitbake core-image-minimal -c populate_sdk
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

Install SDK to host:

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
PACKAGECONFIG ??= "debug"
PACKAGECONFIG[debug] = ""

DEBUG_FLAGS = "-O0 -g -feliminate-unused-debug-types"

CFLAGS:append = "${@bb.utils.contains('PACKAGECONFIG', 'debug', ' ${DEBUG_FLAGS}', '', d)}"
CXXFLAGS:append = "${@bb.utils.contains('PACKAGECONFIG', 'debug', ' ${DEBUG_FLAGS}', '', d)}"

INHIBIT_PACKAGE_STRIP = "${@bb.utils.contains('PACKAGECONFIG', 'debug', '1', '0', d)}"
INHIBIT_SYSROOT_STRIP = "${@bb.utils.contains('PACKAGECONFIG', 'debug', '1', '0', d)}"

EXTRA_OECMAKE:append = "${@bb.utils.contains('PACKAGECONFIG', 'debug', ' -DCMAKE_BUILD_TYPE=Debug', '', d)}"
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
echo "deb [trusted=yes] http://<host-ip>:8000/all ./" > /etc/apt/sources.list.d/yocto.list
echo "deb [trusted=yes] http://<host-ip>:8000/cortexa72 ./" > /etc/apt/sources.list.d/yocto.list
echo "deb [trusted=yes] http://<host-ip>:8000/raspberrypi4_64 ./" > /etc/apt/sources.list.d/yocto.list
apt-get update
```

### Install

```bash
apt install your-app-dbg
apt install gdb # + gdbserver
```

### Verify the target bin is "no stripped"

On host:
> file /opt/poky/5.2.4/sysroots/cortexa72-poky-linux/usr/bin/openhd 
/opt/poky/5.2.4/sysroots/cortexa72-poky-linux/usr/bin/openhd: ELF 64-bit LSB pie executable, ARM aarch64, version 1 (GNU/Linux), dynamically linked, interpreter /usr/lib/ld-linux-aarch64.so.1, BuildID[sha1]=46b59e883e2668b6ae1770f392df6204f8b64a2e, for GNU/Linux 5.15.0, with debug_info, not stripped
Lwq

> file
file test
test: ELF 64-bit LSB pie executable, ARM aarch64, version 1 (GNU/Linux), dynamically linked, interpreter /usr/lib/ld-linux-aarch64.so.1, BuildID[sha1]=46b59e883e2668b6ae1770f392df6204f8b64a2e, for GNU/Linux 5.15.0, with debug_info, not stripped

### Troubleshooting, forced reinstall

> File has unexpected size (28025128 != 730316). Mirror sync in progress? [IP: 192.168.1.102 8000]
> ...
> E: Internal Error, ordering was unable to handle the media swap

```bash
dpkg --remove --force-remove-reinstreq openhd
wget http://192.168.1.102:8000/cortexa72/openhd_1.0+git0+d9ed49108a-r0_arm64.deb
dpkg -i --force-all openhd_1.0+git0+d9ed49108a-r0_arm64.deb
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

# 0. Visual Studio Code Setup

## Required Extensions

* C/C++
* CMake Tools (if applicable)
* Remote - SSH

---

# Proxy Setup (Mac -> Ubuntu -> Raspberry Pi)

## SSH Proxy (recommended)

On Mac (`~/.ssh/config`):

```bash
Host pc
    HostName user
    User pc
```

Set up [Remote Development using SSH](https://code.visualstudio.com/docs/remote/ssh) and open *pc* connection inside VS shell

## Install C/C++ Debug (gdb) on remote

"C/C++ Debug (gdb)" 

## Set up VS code debugger

### Check source folder

-exec info source
>File /usr/src/debug/openhd/1.0+git/OpenHD/ohd_common/src/openhd_util_filesystem.cpp:
185:	int OHDFilesystemUtil::get_remaining_space_in_mb();

Inside your-app source folder:
mkdir .vscode/
cd .vscode/

Create lauch.json:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Yocto Remote Debug (OpenHD)",
      "type": "cppdbg",
      "request": "launch",

      "program": "/opt/poky/5.2.4/sysroots/cortexa72-poky-linux/usr/bin/openhd",
      "args": ["-g"],
      "stopAtEntry": false,
      "cwd": "${workspaceFolder}",
      "MIMode": "gdb",
      "environment": [],
      "externalConsole": false,
      "miDebuggerServerAddress": "192.168.1.137:2345",
      "sourceFileMap": {
        "/usr/src/debug": "${workspaceFolder}",
        "/build/tmp/work/cortexa72-poky-linux/openhd/": "${workspaceFolder}"
      },
      "setupCommands": [
        {
          "text": "set sysroot /opt/poky/5.2.4/sysroots/cortexa72-poky-linux",
          "description": "Set Yocto sysroot"
        },
        {
          "text": "set substitute-path /usr/src/debug/openhd/1.0+git /home/user/Documents/OpenHD/OpenHD",
          "description": "Map Yocto source paths"
        },
        {
          "text": "-enable-pretty-printing",
          "description": "Enable GDB pretty printing",
          "ignoreFailures": true
        }
      ],
      "miDebuggerPath": "/opt/poky/5.2.4/sysroots/x86_64-pokysdk-linux/usr/bin/aarch64-poky-linux/aarch64-poky-linux-gdb",
      "targetArchitecture": "arm64"
    }
  ]
}
```

---

# Minimal Working Debug Sequence

```bash
# Target
gdbserver :2345 /usr/bin/your-app

# Host
source environment-setup-*
$GDB your-app
(gdb) set sysroot $SDKTARGETSYSROOT
(gdb) target remote <ip>:2345
```

---

This setup gives you a reproducible, scalable debugging workflow across Yocto builds, remote targets, and multi-hop network environments.

---

# Useful links
[How to set up Visual Studio Code for Yocto Application Development using CMake](https://fpgafw.pages.desy.de/docs-pub/yocto-doc/vscode_with_cmake_project.html)

