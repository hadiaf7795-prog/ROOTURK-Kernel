#!/bin/bash
set -euo pipefail
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
SRC_ZIP="/mnt/c/Users/TALHA/Desktop/Telefon/evonix-baseline/zip/EVONIX-v2.0-RODIN.zip"
WIN_ZIP="/mnt/c/Users/TALHA/Desktop/Telefon/evonix-baseline/zip"
OUT_DIR="/root/android/dist"
AK3="/root/android/ak3"
IMG="/root/android/out/arch/arm64/boot/Image.gz"
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
ui_print "  Kernel  : 6.6.142-android15-8-4k"
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
ls -lh "$ZIP"
echo PACK_OK
