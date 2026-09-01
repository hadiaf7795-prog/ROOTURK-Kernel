#!/bin/bash
set -euo pipefail
# shellcheck source=env.sh
source "$(cd "$(dirname "$0")" && pwd)/env.sh"

IMG="$KERNEL_OUT/arch/arm64/boot/Image.gz"
NAME="1.0.0-ROOTURK-V1.0"
AK3="$ROOT_DIR/anykernel"

if [ ! -f "$IMG" ]; then
  echo "missing Image.gz: $IMG"
  exit 1
fi
if [ ! -f "$AK3/tools/ak3-core.sh" ]; then
  echo "missing AnyKernel3 tools in $AK3"
  exit 1
fi

mkdir -p "$ROOTURK_ZIP_OUT"
cp -f "$IMG" "$AK3/Image.gz"
rm -f "$AK3/Image" "$AK3/Image.lz4" || true

cd "$AK3"
ZIP="$ROOTURK_ZIP_OUT/${NAME}.zip"
rm -f "$ZIP"
zip -r9 "$ZIP" . -x '*.git*' -x 'Image' -x 'Image.lz4' >/dev/null
ls -lh "$ZIP"
echo PACK_OK
