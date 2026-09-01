# Install ROOTURK Kernel

Türkçe özet: [README.md](README.md) · English overview: [README.en.md](README.en.md)

For **POCO X7 Pro (`rodin`)** only. Wrong device = no boot.

## Before you flash

- Bootloader **unlocked**
- A working custom recovery on **`vendor_boot`** (this phone has **no** `recovery` partition). OrangeFox is the usual choice.
- A backup of the current **`boot`** image (same slot you will flash).
- USB cable. Do **not** use **`fastboot boot`**. Temporary boot of `boot.img` on this device is unsafe.

The flashable zip is AnyKernel3. It unpacks the current `boot` ramdisk, replaces the kernel, and writes **`boot`** back. System, vendor, and recovery are untouched.

## 1. Get the zip

**From source** (this repo):

```bash
bash scripts/build-config.sh
bash scripts/fix-rooturk-config.sh
bash scripts/pack-rooturk.sh
```

Output name: `1.0.0-ROOTURK-V1.0.zip` (see [docs/BUILDING.md](docs/BUILDING.md) for paths).

**From GitHub Releases** if a build is attached to this repository.

Copy the zip to the phone:

```text
adb push 1.0.0-ROOTURK-V1.0.zip /sdcard/Download/
```

## 2. Flash from recovery (recommended)

1. Reboot to recovery.
2. Flash `1.0.0-ROOTURK-V1.0.zip`.
3. Do **not** flash a Magisk apk as a kernel. KernelSU Next is already inside the Image. ROOTURK Manager is inside this zip.
4. Reboot to system.

A/B slot is handled by AnyKernel (`is_slot_device=auto`).

## 3. Flash from Android (already rooted)

If the phone already has superuser:

```text
adb push 1.0.0-ROOTURK-V1.0.zip /sdcard/Download/
adb push scripts/flash_rooturk.sh /data/local/tmp/flash_rooturk.sh
adb shell su -c "sh /data/local/tmp/flash_rooturk.sh"
adb reboot
```

`update-binary` may print `/proc/self/fd/1` warnings on an adb tty. That does not mean the flash failed. Look for `rc=0`.

The running kernel does **not** change until you reboot.

## 4. First boot checks

```text
uname -r
# 6.6.142-1.0.0-ROOTURK-V1.0-android15-8-4k

cat /sys/devices/system/cpu/cpuidle/available_governors
# menu lpm_gov_mhsp          (teo must not appear)

ls /data/adb/ksu             # KernelSU Next data after the manager app runs
```

After reboot, KernelSU module `rooturk-manager` installs ROOTURK Manager as a **system priv-app**. Settings cannot uninstall it. The kernel recognizes that APK’s v2 certificate, so ROOTURK Manager is a KernelSU **manager** (`su` works with no grant popup). KernelSU Next’s own manager APK remains valid. In the app, **Durum → Destek** opens Telegram.

```text
pm path com.rooturk.manager
# package:/system/priv-app/ROOTURKManager/ROOTURKManager.apk

adb shell su -c id
# still works for an already-rooted shell

# inside ROOTURK Manager, Durum should show "Root açık" without opening KernelSU Next
```

Optional Wi-Fi game mode (also installed from the Manager **Network** page):

```text
adb push scripts/98-rooturk-wifi-latency.sh /data/local/tmp/
adb shell su -c "cp /data/local/tmp/98-rooturk-wifi-latency.sh /data/adb/service.d/ && chmod 755 /data/adb/service.d/98-rooturk-wifi-latency.sh"
```

## Unbrick / go back

Keep the previous `boot.img`. In fastboot (Vol− + power):

```text
fastboot flash boot boot_backup.img
```

Use the slot you actually boot (`fastboot flash boot_a` / `boot_b` if needed).  
Again: **`fastboot boot` is not a recovery method on this phone.**

## Support

[t.me/RooTurk](https://t.me/RooTurk)
