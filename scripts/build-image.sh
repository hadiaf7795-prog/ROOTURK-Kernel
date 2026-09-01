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
cd "$SRC"
echo "=== start $(date -Is) ==="
echo "jobs=-j3 ram:"
free -h
make O="$OUT" LLVM=1 LLVM_IAS=1 ARCH=arm64 HOSTCC=gcc HOSTCXX=g++ -j4 Image.gz
echo "=== done $(date -Is) ==="
ls -lh "$OUT/arch/arm64/boot/Image.gz" "$OUT/arch/arm64/boot/Image"
strings "$OUT/arch/arm64/boot/Image" | grep -E 'Linux version|EVONIX|KernelSU' | head
