# ROOTURK Kernel

Custom GKI kernel for the **POCO X7 Pro** (`rodin`) on **Android 16**.

Türkçe: [README.md](README.md)

| | |
|---|---|
| Device | POCO X7 Pro (2412DPC0AG) |
| Android | 16 |
| SoC | MediaTek Dimensity 8400 Ultra (MT6899) |
| Release | `6.6.142-1.0.0-ROOTURK-V1.0-android15-8-4k` |
| Page size | 4K |
| Root | KernelSU Next 3.3.0 (built into the kernel) |
| Hide | SuSFS v2.2.0 (GKI) |

**Telegram:** [t.me/RooTurk](https://t.me/RooTurk)

This repository contains the **full kernel source**, AnyKernel3 packaging, build scripts, and the Wi-Fi latency boot script. **ROOTURK Manager** is not a separate GitHub repo; it is installed from the flash zip.

---

## Features

- **In-kernel KernelSU Next** — no LKM, no `ksu.ko`. ROOTURK Manager is a KernelSU manager (automatic root). KernelSU Next’s own app still works.
- **SuSFS** — suspicious path / mount / kstat / map hiding, uname and cmdline spoof, open-redirect, KSU/SuSFS symbol hiding.
- **Vendor Wi-Fi / BT modules load** — BTF mismatch allowed, module version magic relaxed, in-tree `CFG80211` off so MediaTek `wlan_drv_gen4m_6899` stays in charge.
- **TCP BBR + FQ** — default congestion control is BBR; ROOTURK Manager can still switch Cubic at runtime.
- **ZSWAP on by default** (LZ4 + zbud) and **KSM**.
- **Idle tuned for games** — `CONFIG_CPU_IDLE_GOV_TEO` is **off**. MENU stays; the vendor idle governor `lpm_gov_mhsp` remains available. TEO was parking CPU0 in `s2idle` (~20 ms wake) while WLAN IRQs sat on that little core (see [docs/WIFI.md](docs/WIFI.md)).
- **Vendor ABI** — same `task_struct` layout, ARM64 MTE, and KASAN HW tags as the working stock GKI. `TRIM_UNUSED_KSYMS` is left off (over-trim bootloops this phone).
- **Bypass-charge helper** for the MT6899 / Xiaomi charging path (used with ROOTURK Manager).
- **ROOTURK Manager in the zip** — AnyKernel installs the APK as a system priv-app (cannot be uninstalled). Status → Destek opens Telegram. The kernel matches the APK’s v2 signing cert so the app gets automatic root (no grant popup).
- **AnyKernel3 zip** writes **`boot` only**. Recovery lives on **`vendor_boot`**. Do **not** use `fastboot boot`.

---

## Install

Full steps: **[INSTALL.md](INSTALL.md)**.

Short version:

1. Unlocked bootloader, custom recovery in **`vendor_boot`** (OrangeFox on this device).
2. Build the AnyKernel zip (or use a GitHub Release if one is attached).
3. Flash the zip from recovery **or** from Android with root via `scripts/flash_rooturk.sh`.
4. Reboot. Check:

```text
adb shell uname -r
# 6.6.142-1.0.0-ROOTURK-V1.0-android15-8-4k

adb shell su -c "cat /sys/devices/system/cpu/cpuidle/available_governors"
# menu lpm_gov_mhsp
```

5. Manager is installed as a system app (cannot be uninstalled). The kernel treats its signature as a KernelSU manager (`su` with no grant popup). KernelSU Next’s own manager APK still works.

Optional Wi-Fi game mode (also installed from the Manager **Network** page): `scripts/98-rooturk-wifi-latency.sh`.

---

## Build

Full steps: **[docs/BUILDING.md](docs/BUILDING.md)**.

You need **WSL2 Ubuntu 24.04** (or native Linux), AOSP **Clang r510928**, and about 12 GB RAM.

```bash
git clone --recurse-submodules https://github.com/RooTurkk/ROOTURK-Kernel.git
cd ROOTURK-Kernel
# Clone on Linux/WSL ext4. NTFS cannot store some kernel filenames.
# point CLANG_BIN at your clang-r510928/bin
bash scripts/build-config.sh
bash scripts/fix-rooturk-config.sh   # produces Image.gz
bash scripts/pack-rooturk.sh         # produces 1.0.0-ROOTURK-V1.0.zip
```

Source tree: [`kernel/`](kernel/). Do not enable `TRIM_UNUSED_KSYMS`.

To include Manager in the zip, place a signed `anykernel/rooturk-manager.apk` before packing (`anykernel/*.apk` is gitignored).

---

## Tree

```text
kernel/                                  Linux 6.6 GKI + KernelSU Next + SuSFS
  arch/arm64/configs/gki_defconfig
  arch/arm64/configs/rooturk_gki.config
  KernelSU-Next/
anykernel/                               AnyKernel3 template (boot only)
configs/rooturk.config                   extra fragment (idle, ZSWAP, LOCALVERSION)
scripts/build-config.sh                  gki_defconfig + ROOTURK merge
scripts/fix-rooturk-config.sh            fragment + Image.gz
scripts/build-image.sh                   Image.gz only (existing .config)
scripts/pack-rooturk.sh                  zip
scripts/flash_rooturk.sh                 flash zip on device (su)
scripts/98-rooturk-wifi-latency.sh       boot: Wi-Fi boost / save
docs/BUILDING.md
docs/WIFI.md
INSTALL.md
README.en.md
```

---

## What this zip does not flash

- `vendor_boot` / recovery
- `init_boot` (AK3 uses `split_boot` only if that partition exists; on rodin the payload is `boot`)
- super / system / vendor

ROOTURK Manager is inside this zip; there is no separate app repository.

---

## Support

Telegram: **[https://t.me/RooTurk](https://t.me/RooTurk)**

---

## License

GPL-2.0. See [`LICENSE`](LICENSE) and [`kernel/COPYING`](kernel/COPYING).  
KernelSU Next has its own license under `kernel/KernelSU-Next/LICENSE`.
