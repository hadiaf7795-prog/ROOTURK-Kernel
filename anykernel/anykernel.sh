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
ui_print "  Installing ROOTURK Manager as a system app..."
MOD=/data/adb/modules/rooturk-manager
if [ -f "$home/rooturk-manager.apk" ]; then
    mkdir -p "$MOD/system/priv-app/ROOTURKManager"
    mkdir -p "$MOD/system/etc/permissions"
    mkdir -p "$MOD/system/etc/sysconfig"
    cp -f "$home/rooturk-manager.apk" "$MOD/system/priv-app/ROOTURKManager/ROOTURKManager.apk"
    cp -f "$home/rooturk-module.prop" "$MOD/module.prop"
    cp -f "$home/rooturk-service.sh" "$MOD/service.sh"
    cp -f "$home/rooturk-post-fs-data.sh" "$MOD/post-fs-data.sh"
    cp -f "$home/privapp-permissions-rooturk-manager.xml" "$MOD/system/etc/permissions/privapp-permissions-rooturk-manager.xml"
    cp -f "$home/sysconfig-rooturk-manager.xml" "$MOD/system/etc/sysconfig/rooturk-manager.xml"
    chmod 755 "$MOD/service.sh" "$MOD/post-fs-data.sh"
    chmod 644 "$MOD/system/priv-app/ROOTURKManager/ROOTURKManager.apk"
    touch "$MOD/skip_mount"
    rm -f "$MOD/rooturk-manager.apk" "$MOD/disable"
    ui_print "  Manager staged as priv-app (reboot to apply)."
else
    ui_print "  Manager APK missing from zip (kernel still flashed)."
fi

ui_print " "
ui_print "  Done! Reboot your device."
ui_print " "
