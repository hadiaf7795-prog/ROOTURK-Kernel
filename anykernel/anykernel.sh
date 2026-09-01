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
ui_print "  Installing ROOTURK Manager..."
mkdir -p /data/adb/modules/rooturk-manage
if [ -f "$home/rooturk-manager.apk" ]; then
    cp -f "$home/rooturk-manager.apk" /data/adb/modules/rooturk-manager/rooturk-manager.apk
    cp -f "$home/rooturk-module.prop" /data/adb/modules/rooturk-manager/module.prop
    cp -f "$home/rooturk-service.sh" /data/adb/modules/rooturk-manager/service.sh
    chmod 755 /data/adb/modules/rooturk-manager/service.sh
    rm -f /data/adb/modules/rooturk-manager/disable
    SIZE=$(toybox wc -c < "$home/rooturk-manager.apk" | tr -d ' \n')
    if [ "$(getprop sys.boot_completed)" = 1 ] && [ -n "$SIZE" ]; then
        TMP=/data/local/tmp/rooturk-manager.apk
        cp -f "$home/rooturk-manager.apk" "$TMP"
        chmod 644 "$TMP"
        chcon u:object_r:apk_data_file:s0 "$TMP" 2>/dev/null
        if pm install -r "$TMP" >/dev/null 2>&1; then
            ui_print "  Manager installed."
        else
            ui_print "  Manager staged for first boot."
        fi
        rm -f "$TMP"
    else
        ui_print "  Manager staged for first boot."
    fi
else
    ui_print "  Manager APK missing from zip (kernel still flashed)."
fi

ui_print " "
ui_print "  Done! Reboot your device."
ui_print " "
