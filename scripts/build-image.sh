#!/bin/bash
set -euo pipefail
# shellcheck source=env.sh
source "$(cd "$(dirname "$0")" && pwd)/env.sh"

cd "$KERNEL_SRC"
echo "=== start $(date -Is) ==="
echo "jobs=-j4 ram:"
free -h
make O="$KERNEL_OUT" LLVM=1 LLVM_IAS=1 ARCH=arm64 HOSTCC=gcc HOSTCXX=g++ LOCALVERSION= -j4 Image.gz
echo "=== done $(date -Is) ==="
ls -lh "$KERNEL_OUT/arch/arm64/boot/Image.gz" "$KERNEL_OUT/arch/arm64/boot/Image"
strings "$KERNEL_OUT/arch/arm64/boot/Image" | grep -E 'Linux version 6\.6|ROOTURK|KernelSU' | head
echo BUILD_OK
