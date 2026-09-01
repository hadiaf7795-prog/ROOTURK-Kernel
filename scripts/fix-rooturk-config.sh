#!/bin/bash
set -euo pipefail
export PATH=/root/android/toolchain/clang-r510928/bin:/usr/sbin:/usr/bin:/sbin:/bin
export ARCH=arm64
export LLVM=1
export LLVM_IAS=1
export KCFLAGS="-D__ANDROID_COMMON_KERNEL__"
export CROSS_COMPILE=aarch64-linux-gnu-
export CLANG_TRIPLE=aarch64-linux-gnu-
OUT=/root/android/out
SRC=/root/android/src/common
CFG="$SRC/scripts/config --file $OUT/.config"

cd "$SRC"

# Match working EVONIX v2.0 ABI / hardware features. Do not enable
# TRIM_UNUSED_KSYMS without Kleaf's abi_symbollist.raw (over-trim = bootloop).
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
# TEO mispredicts UDP/game packet gaps, parks CPU0 in s2idle (20ms
# wakeup) while wlan IRQs sit on that CPU. Live A/B on rodin 5 GHz:
# teo max 83ms, menu/lpm max ~12ms. Keep MENU; vendor still adds lpm_gov_mhsp.
$CFG --disable CPU_IDLE_GOV_TEO
$CFG --enable CPU_IDLE_GOV_MENU
sed -i 's/^CONFIG_CPU_IDLE_GOV_TEO=y/# CONFIG_CPU_IDLE_GOV_TEO is not set/' \
  "$SRC/arch/arm64/configs/gki_defconfig" || true

make O="$OUT" LLVM=1 LLVM_IAS=1 ARCH=arm64 HOSTCC=gcc HOSTCXX=g++ olddefconfig

echo "=== post-olddefconfig checks ==="
grep -E 'CONFIG_(LOCALVERSION|GKI_DYNAMIC|GKI_TASK_STRUCT|ARM64_MTE|KASAN_HW_TAGS|ZSWAP_DEFAULT|TRIM_UNUSED|CFI_CLANG|LTO_NONE|CPU_IDLE_GOV_)=' "$OUT/.config" | head -40

python3 - <<'PY'
from pathlib import Path
p = Path("/root/android/src/common/Makefile")
lines = p.read_text().splitlines(True)
out = []
for line in lines:
    if line.startswith("EXTRAVERSION"):
        out.append("EXTRAVERSION = -1.0.0-ROOTURK-V1.0\n")
    else:
        out.append(line)
p.write_text("".join(out))
print("EXTRAVERSION ok")
PY

rm -f "$OUT/include/generated/utsrelease.h" \
      "$OUT/include/config/kernel.release" \
      "$OUT/init/version.o" \
      "$OUT/arch/arm64/boot/Image" \
      "$OUT/arch/arm64/boot/Image.gz"

echo "=== rebuild $(date -Is) ==="
make O="$OUT" LLVM=1 LLVM_IAS=1 ARCH=arm64 HOSTCC=gcc HOSTCXX=g++ LOCALVERSION= -j4 Image.gz
echo "=== uts ==="
cat "$OUT/include/generated/utsrelease.h"
cat "$OUT/include/config/kernel.release"
echo BUILD_OK
