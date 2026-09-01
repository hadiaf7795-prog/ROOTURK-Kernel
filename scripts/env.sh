# sourced by other ROOTURK scripts
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export KERNEL_SRC="${KERNEL_SRC:-$ROOT_DIR/kernel}"
export KERNEL_OUT="${KERNEL_OUT:-$ROOT_DIR/out}"
export CLANG_BIN="${CLANG_BIN:-/root/android/toolchain/clang-r510928/bin}"
export ROOTURK_ZIP_OUT="${ROOTURK_ZIP_OUT:-$ROOT_DIR/dist}"
export PATH="${CLANG_BIN}:/usr/sbin:/usr/bin:/sbin:/bin"
export ARCH=arm64
export LLVM=1
export LLVM_IAS=1
export KCFLAGS="-D__ANDROID_COMMON_KERNEL__"
export CROSS_COMPILE=aarch64-linux-gnu-
export CLANG_TRIPLE=aarch64-linux-gnu-
