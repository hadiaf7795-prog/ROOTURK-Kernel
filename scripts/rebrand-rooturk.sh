#!/bin/bash
set -euo pipefail
export PATH=/root/android/toolchain/clang-r510928/bin:/usr/sbin:/usr/bin:/sbin:/bin
export ARCH=arm64
export LLVM=1
export LLVM_IAS=1
export KCFLAGS="-D__ANDROID_COMMON_KERNEL__"
export CROSS_COMPILE=aarch64-linux-gnu-
export CLANG_TRIPLE=aarch64-linux-gnu-
OUT=/root/android/out
SRC=/root/android/src/common

python3 - <<'PY'
from pathlib import Path
p = Path("/root/android/src/common/Makefile")
lines = p.read_text().splitlines(True)
out = []
for line in lines:
    if line.startswith("EXTRAVERSION"):
        out.append("EXTRAVERSION = -1.0.0-ROOTURK-V1.0\n")
    else:
        out.append(line)
p.write_text("".join(out))
print("EXTRAVERSION set")
PY

# Force uts rebuild
rm -f "$OUT/include/generated/utsrelease.h" \
      "$OUT/include/generated/compile.h" \
      "$OUT/init/version.o" \
      "$OUT/init/utsversion-tmp.h" \
      "$OUT/arch/arm64/boot/Image" \
      "$OUT/arch/arm64/boot/Image.gz"

cd "$SRC"
echo "=== rebuild $(date -Is) ==="
make O="$OUT" LLVM=1 LLVM_IAS=1 ARCH=arm64 HOSTCC=gcc HOSTCXX=g++ -j4 Image.gz
echo "=== uts ==="
cat "$OUT/include/generated/utsrelease.h"

SRC_ZIP="/mnt/c/Users/TALHA/Desktop/Telefon/evonix-baseline/zip/EVONIX-v2.0-RODIN.zip"
WIN_ZIP="/mnt/c/Users/TALHA/Desktop/Telefon/evonix-baseline/zip"
OUT_DIR="/root/android/dist"
AK3="/root/android/ak3"
IMG="$OUT/arch/arm64/boot/Image.gz"
NAME="1.0.0-ROOTURK-V1.0"

mkdir -p "$OUT_DIR"
rm -rf "$AK3"
mkdir -p "$AK3"
unzip -q "$SRC_ZIP" -d "$AK3"
cp -f "$IMG" "$AK3/Image.gz"
rm -f "$AK3/Image" "$AK3/Image.lz4" || true

cat > "$AK3/anykernel.sh" <<'AK'
### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
properties() { '
kernel.string=1.0.0-ROOTURK-V1.0
do.devicecheck=0
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties

### AnyKernel install
block=boot
is_slot_device=auto
ramdisk_compression=auto
patch_vbmeta_flag=auto
no_magisk_check=1

. tools/ak3-core.sh

ui_print " "
ui_print "  +---------------------------------+"
ui_print "  |       1.0.0-ROOTURK-V1.0        |"
ui_print "  +---------------------------------+"
ui_print " "
ui_print "  Device  : Poco X7 Pro (rodin)"
ui_print "  Version : 1.0.0-ROOTURK-V1.0"
ui_print "  Kernel  : Linux 6.6.142 | GKI | 4k"
ui_print " "
ui_print "  Flashing ROOTURK kernel..."

if [ -L "/dev/block/bootdevice/by-name/init_boot_a" -o -L "/dev/block/by-name/init_boot_a" ]; then
    split_boot
    flash_boot
else
    dump_boot
    write_boot
fi

ui_print " "
ui_print "  Done! Reboot your device."
ui_print " "
AK

cd "$AK3"
ZIP="$OUT_DIR/${NAME}.zip"
rm -f "$ZIP"
zip -r9 "$ZIP" . -x '*.git*' >/dev/null
cp -f "$ZIP" "$WIN_ZIP/${NAME}.zip"
cp -f "$IMG" "$WIN_ZIP/Image.gz"
rm -f "$WIN_ZIP/EVONIX-HYPEROS-V3.5-RODIN-local.zip"
ls -lh "$ZIP" "$WIN_ZIP/${NAME}.zip"
echo PACK_OK
