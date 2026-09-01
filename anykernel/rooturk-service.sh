#!/system/bin/sh
MODDIR=${0%/*}
APK="$MODDIR/rooturk-manager.apk"
TMP=/data/local/tmp/rooturk-manager.apk

until [ "$(getprop sys.boot_completed)" = 1 ]; do
  sleep 2
done
sleep 8

[ -f "$APK" ] || exit 0
cp -f "$APK" "$TMP" || exit 1
chmod 644 "$TMP"
chcon u:object_r:apk_data_file:s0 "$TMP" 2>/dev/null || true
pm install -r "$TMP" >/dev/null 2>&1
rm -f "$TMP"
