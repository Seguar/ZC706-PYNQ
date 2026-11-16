#!/usr/bin/env bash
set -euo pipefail
target=${1:?Root filesystem path required}
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
test -f "$target/etc/os-release"
sudo python3 - "$target" <<'DEFAULTS'
from pathlib import Path
import sys
root = Path(sys.argv[1]).resolve()
assert str(root) != '/'
(root/'etc/hostname').write_text('pynq-2\n')
hosts = root/'etc/hosts'
lines = hosts.read_text().splitlines()
lines = [line for line in lines if not (line.split() and line.split()[0] == '127.0.1.1')]
lines.append('127.0.1.1\tpynq-2')
hosts.write_text('\n'.join(lines) + '\n')
(root/'etc/machine-id').write_text('')
for relative in ('var/lib/dbus/machine-id', 'var/lib/systemd/random-seed'):
    path = root/relative
    if path.is_file() and not path.is_symlink(): path.unlink()
for name in ('rsa', 'ecdsa', 'ed25519', 'dsa'):
    for suffix in ('', '.pub'):
        key = root/'etc/ssh'/('ssh_host_' + name + '_key' + suffix)
        if key.exists(): key.unlink()
DEFAULTS
sudo install -m 0644 "$script_dir/zc706-ssh-hostkeys.service" "$target/lib/systemd/system/zc706-ssh-hostkeys.service"
sudo systemctl --root="$target" enable zc706-ssh-hostkeys.service

sudo install -d -m 0755 "$target/etc/systemd/system/ssh.service.d"
printf '[Unit]\nRequires=zc706-ssh-hostkeys.service\nAfter=zc706-ssh-hostkeys.service\n' | sudo tee "$target/etc/systemd/system/ssh.service.d/zc706-hostkeys.conf" >/dev/null
