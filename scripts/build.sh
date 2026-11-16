#!/usr/bin/env bash
set -euo pipefail
repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
work=${BUILD_DIR:-"$repo/work"}
tools=${TOOLS_ROOT:-/tools}
license_dir=${LICENSE_DIR:-"$HOME/.Xilinx"}
[[ "$tools" = /* && "$work" = /* ]]
test "$(git -C "$work/PYNQ" rev-parse HEAD)" = 3c77124d86bab65ac7bb6beb0aa66e13c83508f2
security=()
if [[ -n "${APPARMOR_PROFILE:-}" ]]; then security=(--security-opt "apparmor=$APPARMOR_PROFILE"); fi
docker run --init --rm --network host --privileged "${security[@]}"     -v "$tools:$tools:ro" -v "$license_dir:$license_dir:ro"     -v "$repo:/port" -v "$work/PYNQ:/workspace"     -e XILINXD_LICENSE_FILE="$license_dir"     -e VIVADO_SETTINGS="${VIVADO_SETTINGS:-$tools/Xilinx/Vivado/2024.1/settings64.sh}"     -e VITIS_SETTINGS="${VITIS_SETTINGS:-$tools/Xilinx/Vitis/2024.1/settings64.sh}"     -e PETALINUX_SETTINGS="${PETALINUX_SETTINGS:-$tools/petalinux/2024.1/settings.sh}"     -e PYNQ_BOARDNAME=ZC706 -e FPGA_MANAGER=1 -e ZC706_BOARDDIR=/port/boards/ZC706     -e REBUILD_DTB="${REBUILD_DTB:-0}" pynqdock:zc706-3.1.2 bash -c '
        set -eo pipefail
        source "$VITIS_SETTINGS"
        source "$VIVADO_SETTINGS"
        source "$PETALINUX_SETTINGS"
        export PYNQ_BOARDNAME=ZC706 FPGA_MANAGER=1 ZC706_BOARDDIR=/port/boards/ZC706
        sudo bash /port/scripts/setup-arm-binfmt.sh
        make -C "$ZC706_BOARDDIR/base"
        cd /workspace/sdbuild
        if [[ "$REBUILD_DTB" = 1 && -d build/ZC706/petalinux_project ]]; then
            petalinux-build -c device-tree -x cleansstate -p build/ZC706/petalinux_project
            petalinux-build -c device-tree -p build/ZC706/petalinux_project
        fi
        make BOARDS=ZC706 BOARDDIR=/port/boards
        bash /port/scripts/check-fit.sh output/boot/ZC706/image.ub
    '
