#!/bin/bash
set -euo pipefail
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
SRC_ZIP="/mnt/c/Users/TALHA/Desktop/Telefon/evonix-baseline/zip/EVONIX-v2.0-RODIN.zip"
OUT_DIR="/root/android/dist"
AK3="/root/android/ak3"
IMG="/root/android/out/arch/arm64/boot/Image.gz"
mkdir -p "$OUT_DIR"
rm -rf "$AK3"
mkdir -p "$AK3"
unzip -q "$SRC_ZIP" -d "$AK3"
cp -f "$IMG" "$AK3/Image.gz"
# keep Image if present from v2; AK3 uses Image.gz
rm -f "$AK3/Image" "$AK3/Image.lz4" 2>/dev/null || true
python3 - <<'PY'
from pathlib import Path
p = Path("/root/android/ak3/anykernel.sh")
t = p.read_text(encoding="utf-8", errors="replace")
t = t.replace("Version : Linux 6.6.127 | GKI | v2.0", "Version : Linux 6.6.142 | GKI | HYPEROS-V3.5 local")
t = t.replace("OS      : HyperOS 3 | Android 16", "OS      : AxionAOSP / GKI | local build")
p.write_text(t, encoding="utf-8")
print("anykernel.sh updated")
PY
# strings check
echo "=== Image.gz strings ==="
zcat "$AK3/Image.gz" | strings | grep -E 'Linux version 6\.6|EVONIX|KernelSU' | head -8
cd "$AK3"
rm -f "$OUT_DIR/EVONIX-HYPEROS-V3.5-RODIN-local.zip"
zip -r9 "$OUT_DIR/EVONIX-HYPEROS-V3.5-RODIN-local.zip" . -x '*.git*' >/dev/null
cp -f "$OUT_DIR/EVONIX-HYPEROS-V3.5-RODIN-local.zip" "/mnt/c/Users/TALHA/Desktop/Telefon/evonix-baseline/zip/"
cp -f "$IMG" "/mnt/c/Users/TALHA/Desktop/Telefon/evonix-baseline/zip/Image.gz"
ls -lh "$OUT_DIR/EVONIX-HYPEROS-V3.5-RODIN-local.zip" "$IMG"
echo PACK_OK
