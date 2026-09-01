# Derleme

## Ortam

Windows’ta native `make` yok. WSL2 **Ubuntu 24.04**, pratikte 12 GB RAM + swap.

Örnek yerleşim:

```text
/root/android/src/common          # EVONIX-Kernel (hyperos/ksu-susfs)
/root/android/toolchain/clang-r510928
/root/android/out                 # O= çıktı
```

Clang: Android 15 `clang-r510928` (linux-x86 prebuilt).

Paketler (Ubuntu):

```bash
apt-get install -y git git-lfs build-essential flex bison libssl-dev libelf-dev \
  bc dwarves python3 python-is-python3 wget curl ca-certificates zip unzip \
  rsync pkg-config libncurses-dev cpio kmod xz-utils zstd device-tree-compiler \
  gcc-aarch64-linux-gnu
```

Kaynak:

```bash
git clone --recurse-submodules --depth 1 -b hyperos/ksu-susfs \
  https://github.com/NEESCHAL-3/EVONIX-Kernel.git /root/android/src/common
```

`scripts/patch-setlocalversion.py` ve `patch-extract-cert.py` host araç ırkı / LOCALVERSION için gerekebilir (ilk derlemede görüldü).

## Adımlar

Tüm scriptler `PATH` içine Clang `bin/` koyar, `ARCH=arm64 LLVM=1 LLVM_IAS=1`.

1. **`build-config.sh`**  
   `make gki_defconfig` → `evonix.config` merge → `olddefconfig`.

2. **`fix-rooturk-config.sh`**  
   `configs/rooturk.config` ile aynı anahtarlar: LOCALVERSION, MTE/KASAN, ZSWAP, **TEO kapalı**.  
   `gki_defconfig` içinde `CONFIG_CPU_IDLE_GOV_TEO` satırını da `is not set` yapar (sonraki sade `gki_defconfig` TEO’yu geri getirmesin).  
   Makefile `EXTRAVERSION = -1.0.0-ROOTURK-V1.0`.  
   `make -j4 Image.gz`.

3. Kontrol:

```text
cat /root/android/out/include/generated/utsrelease.h
# 6.6.142-1.0.0-ROOTURK-V1.0-android15-8-4k

grep CPU_IDLE_GOV /root/android/out/.config
# MENU=y, TEO is not set

grep teo_governor /root/android/out/System.map   # boş olmalı
grep menu_governor /root/android/out/System.map  # olmalı
```

4. **`pack-rooturk.sh`**  
   EVONIX AnyKernel3 şablonundan zip üretir, `Image.gz` kopyalar.  
   Varsayılan çıktı yolu script içinde Windows mount’a ayarlıdır; kendi `SRC_ZIP` / `WIN_ZIP` yollarını düzenle.

`TRIM_UNUSED_KSYMS` açma. Vendor `wlan` / `conninfra` GKI sembolleri kesilince cihaz açılmaz.

## Host notları

- `HOSTCC=gcc HOSTCXX=g++` — Clang ile host `extract-cert` ırkı görüldü.
- `LOCALVERSION=` boş geçilir; isim EXTRAVERSION + CONFIG_LOCALVERSION’dan gelir.
- Tam temiz derleme ~45–90 dk (`-j4`). Config-only idle değişikliği daha kısa.
