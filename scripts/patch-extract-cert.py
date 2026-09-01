from pathlib import Path

p = Path("/root/android/src/common/certs/extract-cert.c")
t = p.read_text()
old = """#ifdef USE_PKCS11_ENGINE
static const char *key_pass;
#endif
"""
new = """static const char *key_pass;
"""
if old not in t:
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
