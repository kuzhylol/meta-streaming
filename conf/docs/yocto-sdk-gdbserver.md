# Architecture Overview
| Component | Role | Network IP |
| :--- | :--- | :--- |
| **Mac (Local)** | VS Code UI & SSH Client | - |
| **Ubuntu (Host)** | Build Server, SDK, & GDB Client | `192.168.1.102` |
| **Raspberry Pi (Target)** | Execution & `gdbserver` | `192.168.1.137` |

# SDK Generation & Configuration
Before building the SDK, ensure your local.conf is configured to allow debugging. Without these, Yocto will strip the very symbols you're looking for to save space.

Configure local.conf
```bitbake
# Include gdbserver in the image and gdb in the SDK host
IMAGE_INSTALL:append = " gdbserver"
EXTRA_IMAGE_FEATURES += "dbg-pkgs"
TOOLCHAIN_HOST_TASK:append = " nativesdk-packagegroup-sdk-host"
```
## Build the SDK

You have two choices here. If you are just writing application code, the Standard SDK is usually enough. If you need to modify the underlying libraries, go Extensible.

```bitbake
* Standard SDK: bitbake core-image-minimal -c populate_sdk
* Extensible SDK (eSDK): bitbake core-image-minimal -c populate_sdk_ext

Output Path: tmp/deploy/sdk/
```

# Recipe Configuration (The .bbappend)
To debug effectively, you must disable compiler optimizations. Otherwise, the instruction pointer will jump around like a caffeinated squirrel, and variables will be "optimized out."

Code snippet
## recipes-foo/your-app/your-app.bbappend

### 1. Force Debug Mode
```
PACKAGECONFIG:append = " debug"
PACKAGECONFIG[debug] = ""
```

### 2. Set Compiler Flags: -O0 disables optimization, -g adds symbols
```
DEBUG_FLAGS = "-O0 -g -feliminate-unused-debug-types"

CFLAGS:append = "${@bb.utils.contains('PACKAGECONFIG', 'debug', ' ${DEBUG_FLAGS}', '', d)}"
CXXFLAGS:append = "${@bb.utils.contains('PACKAGECONFIG', 'debug', ' ${DEBUG_FLAGS}', '', d)}"
```

### 3. Prevent Yocto from stripping the binary
```
INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
```

# Deployment via Local Repository
Instead of manual scp, using a local apt repo is much cleaner for managing dependencies and debug symbols.

On the Ubuntu Host (Start HTTP Server)

```bash
start-stop-daemon --start --background --make-pidfile --pidfile /tmp/yocto-http.pid \
  --chdir tmp/deploy/deb \
  --exec /usr/bin/python3 -- -m http.server 8000
```

On the Raspberry Pi (Target)

Create /etc/apt/sources.list.d/yocto.list:

```bash
deb [trusted=yes] http://192.168.1.102:8000/all ./
deb [trusted=yes] http://192.168.1.102:8000/cortexa72 ./
deb [trusted=yes] http://192.168.1.102:8000/raspberrypi4_64 ./
```
Then update and install:

```bash
apt update && apt install your-app-dbg gdbserver
```

###
### Verify the target elf is "not stripped"

On host:
```
> file /opt/poky/5.2.4/sysroots/cortexa72-poky-linux/usr/bin/openhd
/opt/poky/5.2.4/sysroots/cortexa72-poky-linux/usr/bin/openhd: ELF 64-bit LSB pie executable, ARM aarch64, version 1 (GNU/Linux), dynamically linked, interpreter /usr/lib/ld-linux-aarch64.so.1, BuildID[sha1]=46b59e883e2668b6ae1770f392df6204f8b64a2e, for GNU/Linux 5.15.0, with debug_info, not stripped
```

On target:
```
file openhd
test: ELF 64-bit LSB pie executable, ARM aarch64, version 1 (GNU/Linux), dynamically linked, interpreter /usr/lib/ld-linux-aarch64.so.1, BuildID[sha1]=46b59e883e2668b6ae1770f392df6204f8b64a2e, for GNU/Linux 5.15.0, with debug_info, not stripped
```

# VS Code Setup
This setup assumes you have used Remote-SSH to connect VS Code on your Mac to the Ubuntu Host.

launch.json Configuration

The critical parts here are sourceFileMap and setupCommands. This tells GDB where to find the source code when the binary points to a Yocto build directory that might not exist on your host.

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Yocto Remote Debug",
      "type": "cppdbg",
      "request": "launch",
      "program": "/opt/poky/5.2.4/sysroots/cortexa72-poky-linux/usr/bin/openhd",
      "args": [],
      "stopAtEntry": false,
      "cwd": "${workspaceFolder}",
      "MIMode": "gdb",
      "miDebuggerServerAddress": "192.168.1.137:2345",
      "targetArchitecture": "arm64",
      "miDebuggerPath": "/opt/poky/5.2.4/sysroots/x86_64-pokysdk-linux/usr/bin/aarch64-poky-linux/aarch64-poky-linux-gdb",
      "sourceFileMap": {
        "/usr/src/debug": "${workspaceFolder}",
        "/build/tmp/work": "${workspaceFolder}"
      },
      "setupCommands": [
        {
          "text": "set sysroot /opt/poky/5.2.4/sysroots/cortexa72-poky-linux",
          "description": "Critical: Set sysroot so GDB finds shared libraries"
        },
        {
          "text": "set substitute-path /usr/src/debug/openhd/1.0+git /home/user/project/src",
          "description": "Maps Yocto build paths to your local source"
        },
        {
          "text": "-enable-pretty-printing",
          "ignoreFailures": true
        }
      ]
    }
  ]
}
```

# Edge Cases & Troubleshooting
## Case A: "File has unexpected size" (APT Errors)

Yocto's package-index isn't always updated automatically. If apt complains about size mismatches:

* On Host: `Run bitbake package-index`
* On Target: `Run apt clean && apt update`

## Case B: Shared Libraries Not Loading Symbols
If you see ?? in the call stack for system libraries:

Ensure you have set sysroot in your launch.json.

Verify the library exists in the SDK sysroot: `ls /opt/poky/.../usr/lib/libyourlib.so`.

## Case C: The "Missing Source" Problem

If GDB finds the binary but says No such file or directory when trying to show code:

In the VS Code Debug Console, type -exec info source.

Look at the "Compilation directory." Use that path in your substitute-path or sourceFileMap.

## Case D: Firewall/Port Issues

If VS Code can't connect to gdbserver:

Check if gdbserver is actually listening: `netstat -tunlp | grep 2345` on the Pi.

Ensure the Pi can reach the Ubuntu host and vice versa. Some corporate Wi-Fi blocks peer-to-peer traffic.

##### Packet size mismatch

```
File has unexpected size (28025128 != 730316). Mirror sync in progress? [IP: 192.168.1.102 8000]
...
E: Internal Error, ordering was unable to handle the media swap
```

Solution is forced package reinstall:

```bash
dpkg --remove --force-remove-reinstreq openhd
wget http://192.168.1.102:8000/cortexa72/openhd_1.0+git0+d9ed49108a-r0_arm64.deb
dpkg -i --force-all openhd_1.0+git0+d9ed49108a-r0_arm64.deb
```

# Quick Start Cheat Sheet
Target: `gdbserver :2345 /usr/bin/your-app`

Host (VS Code): Press F5.

Profit. (Or debug, which is essentially anti-profit until it works).
