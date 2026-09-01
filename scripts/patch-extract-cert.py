import os
from pathlib import Path

src = Path(os.environ.get("KERNEL_SRC", "kernel"))
p = src / "certs" / "extract-cert.c"
t = p.read_text()
old = """#ifdef USE_PKCS11_ENGINE
static const char *key_pass;
#endif
"""
new = """static const char *key_pass;
"""
if old not in t:
    if "static const char *key_pass;" in t and "KBUILD_SIGN_PIN" in t:
        print("extract-cert.c already patched")
        raise SystemExit(0)
    raise SystemExit("pattern1 not found")
t = t.replace(old, new, 1)
old2 = """#ifdef USE_PKCS11_ENGINE
	key_pass = getenv("KBUILD_SIGN_PIN");
#endif
"""
new2 = """	key_pass = getenv("KBUILD_SIGN_PIN");
"""
if old2 not in t:
    raise SystemExit("pattern2 not found")
t = t.replace(old2, new2, 1)
p.write_text(t)
print("patched extract-cert.c")
