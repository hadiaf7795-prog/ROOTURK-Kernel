#!/bin/bash
set -euo pipefail
# shellcheck source=env.sh
source "$(cd "$(dirname "$0")" && pwd)/env.sh"

CFG="$KERNEL_SRC/scripts/config --file $KERNEL_OUT/.config"
cd "$KERNEL_SRC"

# Vendor ABI / hardware. Do not enable TRIM_UNUSED_KSYMS without a
# Kleaf abi_symbollist.raw (over-trim = bootloop on rodin).
$CFG --set-str LOCALVERSION "-android15-8-4k"
$CFG --disable LOCALVERSION_AUTO
$CFG --disable GKI_DYNAMIC_TASK_STRUCT_SIZE
$CFG --disable GKI_TASK_STRUCT_VENDOR_SIZE_MAX
$CFG --disable ARCH_WANTS_DYNAMIC_TASK_STRUCT
$CFG --enable ARM64_MTE
$CFG --enable KASAN
$CFG --enable KASAN_HW_TAGS
$CFG --enable KASAN_VMALLOC
$CFG --enable ZSWAP
$CFG --enable ZSWAP_DEFAULT_ON
$CFG --enable ZPOOL
$CFG --enable ZBUD
$CFG --enable ZSWAP_ZPOOL_DEFAULT_ZBUD
$CFG --enable ZSWAP_COMPRESSOR_DEFAULT_LZ4
$CFG --enable KSM
$CFG --enable TLS
$CFG --enable STREAM_PARSER
$CFG --enable MEMFD_ASHMEM_SHIM
$CFG --enable PM_AUTOSLEEP
$CFG --disable MODULE_SIG_FORCE
$CFG --disable MODULE_SIG_PROTECT
# TEO mispredicts UDP/game packet gaps, parks CPU0 in s2idle (~20 ms
# wakeup) while wlan IRQs sit on that CPU. Keep MENU; vendor still
# provides lpm_gov_mhsp.
$CFG --disable CPU_IDLE_GOV_TEO
$CFG --enable CPU_IDLE_GOV_MENU
sed -i 's/^CONFIG_CPU_IDLE_GOV_TEO=y/# CONFIG_CPU_IDLE_GOV_TEO is not set/' \
  "$KERNEL_SRC/arch/arm64/configs/gki_defconfig" || true

make O="$KERNEL_OUT" LLVM=1 LLVM_IAS=1 ARCH=arm64 HOSTCC=gcc HOSTCXX=g++ olddefconfig

echo "=== post-olddefconfig checks ==="
grep -E 'CONFIG_(LOCALVERSION|GKI_DYNAMIC|GKI_TASK_STRUCT|ARM64_MTE|KASAN_HW_TAGS|ZSWAP_DEFAULT|TRIM_UNUSED|CFI_CLANG|LTO_NONE|CPU_IDLE_GOV_)=' "$KERNEL_OUT/.config" | head -40

python3 - <<'PY'
import os
from pathlib import Path
p = Path(os.environ["KERNEL_SRC"]) / "Makefile"
lines = p.read_text().splitlines(True)
out = []
for line in lines:
    if line.startswith("EXTRAVERSION"):
        out.append("EXTRAVERSION = -1.0.0-ROOTURK-V1.0\n")
    elif line.startswith("NAME ="):
        out.append("NAME = ROOTURK\n")
    else:
        out.append(line)
p.write_text("".join(out))
print("EXTRAVERSION / NAME ok")
PY

rm -f "$KERNEL_OUT/include/generated/utsrelease.h" \
      "$KERNEL_OUT/include/config/kernel.release" \
      "$KERNEL_OUT/init/version.o" \
      "$KERNEL_OUT/arch/arm64/boot/Image" \
      "$KERNEL_OUT/arch/arm64/boot/Image.gz"

echo "=== rebuild $(date -Is) ==="
make O="$KERNEL_OUT" LLVM=1 LLVM_IAS=1 ARCH=arm64 HOSTCC=gcc HOSTCXX=g++ LOCALVERSION= -j4 Image.gz
echo "=== uts ==="
cat "$KERNEL_OUT/include/generated/utsrelease.h"
cat "$KERNEL_OUT/include/config/kernel.release"
echo BUILD_OK
