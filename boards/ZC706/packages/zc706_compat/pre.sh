#!/usr/bin/env bash
set -euo pipefail
target=${1:?Root filesystem required}
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
sudo python3 "$script_dir/configure-pynq-clock.py" "$target"
