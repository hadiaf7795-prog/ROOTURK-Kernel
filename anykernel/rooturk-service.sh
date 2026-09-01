#!/system/bin/sh
# After the priv-app overlay is mounted, drop leftover user copies so
# Settings cannot uninstall ROOTURK Manager.

until [ "$(getprop sys.boot_completed)" = 1 ]; do
  sleep 2
done
sleep 8

[ -f /system/priv-app/ROOTURKManager/ROOTURKManager.apk ] || exit 0

PKG=com.rooturk.manager
PATHS=$(pm path "$PKG" 2>/dev/null | cut -d: -f2)
echo "$PATHS" | grep -q '/data/app/' || exit 0
pm uninstall "$PKG" >/dev/null 2>&1 || true
