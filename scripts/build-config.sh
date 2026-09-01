#!/bin/bash
set -euo pipefail
# shellcheck source=env.sh
source "$(cd "$(dirname "$0")" && pwd)/env.sh"

mkdir -p "$KERNEL_OUT"
cd "$KERNEL_SRC"
echo "=== clang ==="
clang --version | head -1
echo "=== gki_defconfig ==="
make O="$KERNEL_OUT" LLVM=1 LLVM_IAS=1 ARCH=arm64 gki_defconfig
echo "=== merge rooturk_gki.config ==="
./scripts/kconfig/merge_config.sh -O "$KERNEL_OUT" -m "$KERNEL_OUT/.config" \
  arch/arm64/configs/rooturk_gki.config
make O="$KERNEL_OUT" LLVM=1 LLVM_IAS=1 ARCH=arm64 olddefconfig
echo "=== key configs ==="
grep -E 'CONFIG_(KSU|KSU_SUSFS|SECURITY_SELINUX|LTO|CFI_CLANG|KPROBES|DEFAULT_TCP_CONG|CFG80211)=' "$KERNEL_OUT/.config" | head -60
echo CONFIG_OK
