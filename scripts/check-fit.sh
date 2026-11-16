#!/usr/bin/env bash
# Requires u-boot-tools and device-tree-compiler.
set -euo pipefail
fit=${1:?Usage: check-fit.sh image.ub}
dtb=$(mktemp --suffix=.dtb)
trap 'rm -- "$dtb"' EXIT
dumpimage -T flat_dt -p 1 -o "$dtb" "$fit"
test "$(fdtget -t s "$dtb" /chosen pynq_board)" = ZC706
test "$(fdtget -t x "$dtb" /memory reg)" = "0 40000000"
test "$(fdtget -t s "$dtb" /chosen stdout-path)" = serial0:115200n8
fdtget -t s "$dtb" /chosen bootargs | grep -q 'console=ttyPS0,115200n8'
test "$(fdtget -t x "$dtb" /axi/ethernet@e000b000/ethernet-phy@7 reg)" = 7
test "$(fdtget -t x "$dtb" /axi/ethernet@e000b000 phy-handle)" = "$(fdtget -t x "$dtb" /axi/ethernet@e000b000/ethernet-phy@7 phandle)"
if fdtget -p "$dtb" /axi/interrupt-controller@70000000 >/dev/null 2>&1; then
    echo 'FAIL: nonexistent PL interrupt controller in boot tree' >&2; exit 1
fi
fdtget -t s "$dtb" /axi/zyxclmm_drm compatible | grep -q xlnx,zocl
if fdtget -p "$dtb" /axi/zyxclmm_drm | grep -q interrupts; then
    echo 'FAIL: zocl must use polling mode' >&2; exit 1
fi
echo 'PASS: ZC706, 1 GiB, UART1, PHY 7, polling zocl, no legacy PL INTC'
