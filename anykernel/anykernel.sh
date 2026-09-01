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
