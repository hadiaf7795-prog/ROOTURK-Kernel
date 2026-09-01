# Building ROOTURK Kernel

Standalone GKI build (no Kleaf / no full AOSP tree). Target: `Image.gz` for AnyKernel3.

## Environment

Windows cannot run this `make` natively. Use **WSL2 Ubuntu 24.04** or a Linux box. Plan for **12 GB RAM** plus swap.

Suggested layout:

```text
~/ROOTURK-Kernel                 # this git clone (keep it on Linux ext4, not /mnt/c)
/root/android/toolchain/clang-r510928
```

Clone on the Windows NTFS mount (`/mnt/c/...`) if you want, but the build will be much slower.

### Clang

AOSP **clang-r510928** (linux-x86 prebuilt). Put `bin/` on `PATH`, or:

```bash
export CLANG_BIN=/root/android/toolchain/clang-r510928/bin
```

### Packages (Ubuntu)

```bash
apt-get install -y git git-lfs build-essential flex bison libssl-dev libelf-dev \
  bc dwarves python3 python-is-python3 wget curl ca-certificates zip unzip \
  rsync pkg-config libncurses-dev cpio kmod xz-utils zstd device-tree-compiler \
  gcc-aarch64-linux-gnu
```

### Get the source

```bash
git clone --recurse-submodules https://github.com/RooTurkk/ROOTURK-Kernel.git
cd ROOTURK-Kernel
```

The kernel lives in `kernel/`. KernelSU Next is already vendored under `kernel/KernelSU-Next/`.

Clone on **Linux / WSL ext4**. The tree contains files that differ only by case (`xt_CONNMARK.h` vs `xt_connmark.h`). A checkout on Windows NTFS cannot hold both.

One-time host patches are **already applied** in `kernel/`. Re-run only if you replace that tree with stock GKI:

```bash
export KERNEL_SRC="$PWD/kernel"
python3 scripts/patch-setlocalversion.py
python3 scripts/patch-extract-cert.py
```

## Build steps

Scripts set `ARCH=arm64 LLVM=1 LLVM_IAS=1` and prefer `HOSTCC=gcc`.

1. **`scripts/build-config.sh`**  
   `make gki_defconfig` → merge `kernel/arch/arm64/configs/rooturk_gki.config` → `olddefconfig`.

2. **`scripts/fix-rooturk-config.sh`**  
   Applies `configs/rooturk.config`: `LOCALVERSION=-android15-8-4k`, MTE / KASAN HW tags, ZSWAP, **TEO off**, MENU on.  
   Also forces `CONFIG_CPU_IDLE_GOV_TEO` off in `gki_defconfig` so a later plain defconfig does not turn TEO back on.  
   Sets `EXTRAVERSION = -1.0.0-ROOTURK-V1.0`.  
   Runs `make -j4 Image.gz`.

3. Confirm:

```text
cat out/include/generated/utsrelease.h
# 6.6.142-1.0.0-ROOTURK-V1.0-android15-8-4k

grep CPU_IDLE_GOV out/.config
# MENU=y, TEO is not set

grep teo_governor out/System.map    # must be empty
grep menu_governor out/System.map   # must exist
```

4. **`scripts/pack-rooturk.sh`**  
   Copies `Image.gz` into `anykernel/` and zips `1.0.0-ROOTURK-V1.0.zip`.

Override paths if needed:

```bash
export KERNEL_SRC=/path/to/kernel
export KERNEL_OUT=/path/to/out
export CLANG_BIN=/path/to/clang-r510928/bin
export ROOTURK_ZIP_OUT=/path/to/dist
```

## Rules that keep the phone booting

- Do **not** enable `TRIM_UNUSED_KSYMS` without a Kleaf symbol whitelist. Vendor `wlan` / `conninfra` need GKI exports; trim = bootloop.
- Do **not** force `MODULE_SIG_FORCE` / `MODULE_SIG_PROTECT` if you still load OEM modules.
- Keep `HOSTCC=gcc` for `extract-cert` if Clang miscompiles the host tool.
- Pass `LOCALVERSION=` (empty) on the `make` line so the name comes from `EXTRAVERSION` + `CONFIG_LOCALVERSION` only. Git `-dirty` suffixes break vendor vermagic.
- Clean Image.gz build is about **45–90 minutes** at `-j4`. Config-only idle changes are shorter.

## Incremental Image only

If `.config` is already correct:

```bash
bash scripts/build-image.sh
```
