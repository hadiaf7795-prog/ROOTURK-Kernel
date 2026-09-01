#!/system/bin/sh
# f2fs /data is casefold-capable, so it cannot be an overlayfs upper.
# Stage new priv-app files on tmpfs (/dev) and overlay them onto EROFS.
MODDIR=${0%/*}
OV=/dev/rooturk-ov

ov() {
  _tgt="$1"
  _name="$2"
  _src="$3"
  _upper="$OV/${_name}-upper"
  _work="$OV/${_name}-work"
  mkdir -p "$_upper" "$_work"
  if [ -f "$_src" ]; then
    cp -f "$_src" "$_upper/$(basename "$_src")"
    chmod 644 "$_upper/$(basename "$_src")"
    chcon u:object_r:system_file:s0 "$_upper/$(basename "$_src")" 2>/dev/null || true
  fi
  grep -q " $_tgt " /proc/mounts && return 0
  mount -t overlay "rooturk-${_name}" \
    -o "lowerdir=${_tgt},upperdir=${_upper},workdir=${_work}" \
    "$_tgt"
}

mkdir -p "$OV/priv-upper/ROOTURKManager" "$OV/priv-work"
APK="$MODDIR/system/priv-app/ROOTURKManager/ROOTURKManager.apk"
if [ -f "$APK" ]; then
  cp -f "$APK" "$OV/priv-upper/ROOTURKManager/ROOTURKManager.apk"
  chmod 644 "$OV/priv-upper/ROOTURKManager/ROOTURKManager.apk"
  chcon u:object_r:system_file:s0 \
    "$OV/priv-upper" \
    "$OV/priv-upper/ROOTURKManager" \
    "$OV/priv-upper/ROOTURKManager/ROOTURKManager.apk" 2>/dev/null || true
fi
if ! grep -q ' /system/priv-app ' /proc/mounts; then
  mount -t overlay rooturk-priv-app \
    -o "lowerdir=/system/priv-app,upperdir=$OV/priv-upper,workdir=$OV/priv-work" \
    /system/priv-app
fi

ov /system/etc/permissions perm \
  "$MODDIR/system/etc/permissions/privapp-permissions-rooturk-manager.xml"
ov /system/etc/sysconfig sysconfig \
  "$MODDIR/system/etc/sysconfig/rooturk-manager.xml"
