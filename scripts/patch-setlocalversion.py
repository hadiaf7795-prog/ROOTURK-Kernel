import os
from pathlib import Path

src = Path(os.environ.get("KERNEL_SRC", "kernel"))
p = src / "scripts" / "setlocalversion"
t = p.read_text()
old = '''# version string from CONFIG_LOCALVERSION
config_localversion=$(sed -n 's/^CONFIG_LOCALVERSION=\\(.*\\)$/\\1/p' include/config/auto.conf)

# scm version string if not at the kernel version tag or at the file_localversion
if grep -q "^CONFIG_LOCALVERSION_AUTO=y$" include/config/auto.conf; then
	# full scm version string
	scm_version="$(scm_version)"
elif [ "${LOCALVERSION+set}" != "set" ]; then
	# If the variable LOCALVERSION is not set, append a plus
	# sign if the repository is not in a clean annotated or
	# signed tagged state (as git describe only looks at signed
	# or annotated tags - git tag -a/-s).
	#
	# If the variable LOCALVERSION is set (including being set
	# to an empty string), we don't want to append a plus sign.
	scm_version="$(scm_version --short)"
fi

echo "${KERNELVERSION}"
'''
new = '''# version string from CONFIG_LOCALVERSION (unquote)
config_localversion=$(sed -n 's/^CONFIG_LOCALVERSION=//p' include/config/auto.conf | tr -d '"')

# Kleaf normally injects -android15-8; standalone builds must append here.
# Do not append git -g/-dirty (breaks GKI vermagic).
echo "${KERNELVERSION}${config_localversion}${LOCALVERSION}"
'''
if old not in t:
    if "Do not append git -g/-dirty" in t:
        print("setlocalversion already patched")
        raise SystemExit(0)
    raise SystemExit("pattern not found")
p.write_text(t.replace(old, new, 1))
print("setlocalversion patched")
