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
mkdir -p "$OUT"
cd "$SRC"
echo "=== clang ==="
clang --version | head -1
echo "=== gki_defconfig ==="
make O="$OUT" LLVM=1 LLVM_IAS=1 ARCH=arm64 gki_defconfig
echo "=== merge evonix.config ==="
./scripts/kconfig/merge_config.sh -O "$OUT" -m "$OUT/.config" arch/arm64/configs/evonix.config
make O="$OUT" LLVM=1 LLVM_IAS=1 ARCH=arm64 olddefconfig
echo "=== key configs ==="
grep -E 'CONFIG_(KSU|KSU_SUSFS|SECURITY_SELINUX|LTO|CFI_CLANG|KPROBES|DEFAULT_TCP_CONG|CFG80211)=' "$OUT/.config" | head -60
echo CONFIG_OK
