#!/usr/bin/env bash
# Run as root inside the privileged PYNQ build container.
set -euo pipefail
mountpoint -q /proc/sys/fs/binfmt_misc || mount -t binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc
python3 - <<'PY'
from pathlib import Path
root = Path('/proc/sys/fs/binfmt_misc')
name = 'qemu-arm-pynq'
entry = root / name
if entry.exists():
    if 'enabled' not in entry.read_text().splitlines()[0]:
        entry.write_text('1')
else:
    magic = r'\x7f\x45\x4c\x46\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00'
    mask = r'\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'
    (root / 'register').write_text(f':{name}:M::{magic}:{mask}:/opt/qemu/bin/qemu-arm:F')
print(entry.read_text())
PY
