from pathlib import Path

def parse(p):
    d = {}
    for line in Path(p).read_text(errors="replace").splitlines():
        line = line.strip()
        if line.startswith("CONFIG_") and "=" in line:
            k, v = line.split("=", 1)
            d[k] = v
        elif line.startswith("# CONFIG_") and line.endswith(" is not set"):
            k = line[2:].split()[0]
            d[k] = "n"
    return d

raw = Path("/mnt/c/Users/TALHA/WSL/evonix-v20.config").read_bytes()
text = raw.decode("utf-16") if raw.startswith(b"\xff\xfe") else raw.decode()
Path("/tmp/v20.cfg").write_text(text)
a = parse("/tmp/v20.cfg")
b = parse("/root/android/out/.config")
keys = [
    "CONFIG_LTO_NONE", "CONFIG_LTO_CLANG_THIN", "CONFIG_CFI_CLANG",
    "CONFIG_KASAN", "CONFIG_KASAN_HW_TAGS", "CONFIG_ARM64_MTE",
    "CONFIG_LOCALVERSION", "CONFIG_LOCALVERSION_AUTO",
    "CONFIG_TRIM_UNUSED_KSYMS", "CONFIG_UNUSED_KSYMS_WHITELIST",
    "CONFIG_MODULE_SIG_PROTECT", "CONFIG_MODULE_SIG_FORCE", "CONFIG_MODULE_SIG_ALL",
    "CONFIG_CFG80211", "CONFIG_KSU", "CONFIG_KSU_SUSFS",
    "CONFIG_DEBUG_INFO_BTF", "CONFIG_KPROBES",
]
print("KEY | v2.0 working | our ROOTURK")
for k in keys:
    print(f"{k} | {a.get(k, '?')} | {b.get(k, '?')}")

only_v2 = sorted(k for k, v in a.items() if v not in ("n", "") and b.get(k, "n") in ("n", ""))
only_ours = sorted(k for k, v in b.items() if v not in ("n", "") and a.get(k, "n") in ("n", ""))
print(f"\n=== enabled in v2.0, missing/off in ours ({len(only_v2)}) ===")
print("\n".join(only_v2))
print(f"\n=== enabled in ours, missing/off in v2.0 ({len(only_ours)}) ===")
print("\n".join(only_ours))
