#!/usr/bin/env bash
set -euo pipefail
repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
work=${BUILD_DIR:-"$repo/work"}
mkdir -p "$work"
if [[ ! -d "$work/PYNQ/.git" ]]; then
    git clone --branch v3.1.2 --depth 1 --recursive https://github.com/Xilinx/PYNQ.git "$work/PYNQ"
fi
test "$(git -C "$work/PYNQ" rev-parse HEAD)" = 3c77124d86bab65ac7bb6beb0aa66e13c83508f2
mkdir -p "$work/PYNQ/sdbuild/prebuilt"
python3 - "$repo" "$work" <<'INPUTS'
import hashlib, json, sys, urllib.request
from pathlib import Path
repo, work = map(Path, sys.argv[1:])
inputs = json.loads((repo/'docs/build-inputs.json').read_text())
for key, name in [('sdist', 'pynq_sdist.tar.gz'), ('rootfs', 'pynq_rootfs.arm.tar.gz')]:
    info = inputs[key]
    path = work/'PYNQ/sdbuild/prebuilt'/name
    if not path.exists():
        urllib.request.urlretrieve(info['url'], path)
    with path.open('rb') as stream:
        actual = hashlib.file_digest(stream, 'sha256').hexdigest() if hasattr(hashlib, 'file_digest') else None
    if actual is None:
        digest = hashlib.sha256()
        with path.open('rb') as stream:
            for block in iter(lambda: stream.read(8*1024*1024), b''): digest.update(block)
        actual = digest.hexdigest()
    assert actual == info['sha256'], 'Input checksum mismatch: ' + name
    print(name + ': SHA256 OK')
INPUTS
# Upstream 3.1.2 clones these dependencies from moving default branches.
python3 - "$work/PYNQ/sdbuild/packages/pynq/qemu.sh" <<'PIN'
from pathlib import Path
import sys
path=Path(sys.argv[1]);text=path.read_text()
for repo,commit in [('PYNQ-Metadata','7ff39f7e699b854973e4f894fb6e5272534a42f7'),('PYNQ-Utils','fe88b2fd04b6789bd2c9d50c47b140e8453a6886')]:
    url='git+https://github.com/Xilinx/'+repo+'.git'
    if url+'@'+commit not in text:
        assert url in text
        text=text.replace(url,url+'@'+commit)
path.write_text(text)
PIN
docker build --build-arg USERNAME="$(id -un)" --build-arg USER_UID="$(id -u)" --build-arg USER_GID="$(id -g)" -t pynqdock:zc706-3.1.2 "$work/PYNQ/sdbuild"
