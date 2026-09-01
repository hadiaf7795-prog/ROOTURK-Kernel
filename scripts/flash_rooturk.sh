#!/system/bin/sh
set -x
export AKHOME=/data/local/tmp/ak3-rooturk
ZIP=/sdcard/Download/1.0.0-ROOTURK-V1.0.zip
BINDIR=/data/local/tmp/ak3-bin-rooturk

if [ ! -f "$ZIP" ]; then
  echo "ZIP missing: $ZIP"
  exit 2
fi

rm -rf "$AKHOME" "$BINDIR"
mkdir -p "$BINDIR"
/system/bin/unzip -o "$ZIP" "META-INF/com/google/android/update-binary" -d "$BINDIR"
if [ ! -f "$BINDIR/META-INF/com/google/android/update-binary" ]; then
  echo "update-binary extract failed"
  exit 3
fi

echo "=== AK3 START ==="
/system/bin/sh "$BINDIR/META-INF/com/google/android/update-binary" 3 1 "$ZIP"
rc=$?
echo "=== AK3 END rc=$rc ==="
exit $rc
