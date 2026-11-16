#!/usr/bin/env python3
# PYNQ clock-method adaptation: Copyright (C) 2016-2022 Xilinx, Inc.
# SPDX-License-Identifier: BSD-3-Clause
"""Teach PYNQ 3.1.2's Zynq clock model to use the device-tree PS clock."""
import ast
import sys
from pathlib import Path

NEEDLE = '''    def __init__(self, ref_clk_mhz=DEFAULT_SRC_CLK_MHZ, device=None):
        self._ref_clk_mhz = ref_clk_mhz
'''
REPLACEMENT = '''    def __init__(self, ref_clk_mhz=None, device=None):
        # ZC706 PS_CLK is 33 1/3 MHz; PYNQ-Z1/Z2 use 50 MHz.
        # Read the hardware description rather than scaling every reported
        # CPU/PL rate by a board-independent 50 MHz assumption.
        if ref_clk_mhz is None:
            from pathlib import Path
            clock_path = Path('/proc/device-tree/axi/slcr@f8000000/clkc@100/ps-clk-frequency')
            try:
                raw_clock = clock_path.read_bytes()
            except FileNotFoundError:
                ref_clk_mhz = self.DEFAULT_SRC_CLK_MHZ
            else:
                if len(raw_clock) != 4:
                    raise ValueError('Invalid device-tree PS clock frequency')
                clock_hz = int.from_bytes(raw_clock, 'big')
                if not 1_000_000 <= clock_hz <= 100_000_000:
                    raise ValueError('Unsupported device-tree PS clock frequency')
                ref_clk_mhz = clock_hz / 1_000_000.0
        self._ref_clk_mhz = ref_clk_mhz
'''

def patched(source):
    if REPLACEMENT in source:
        return source
    assert source.count(NEEDLE) == 1, 'Unexpected PYNQ ps.py version; refusing patch'
    result = source.replace(NEEDLE, REPLACEMENT)
    ast.parse(result)
    return result

if __name__ == '__main__':
    root = Path(sys.argv[1]).resolve()
    matches = list(root.glob('usr/local/share/pynq-venv/lib/python*/site-packages/pynq/ps.py'))
    assert len(matches) == 1, 'Expected one PYNQ installation'
    path = matches[0]
    original = path.read_text()
    updated = patched(original)
    backup = path.with_name('ps.py.before-zc706-clock')
    if not backup.exists():
        backup.write_text(original)
    path.write_text(updated)
    print('PYNQ clock model: device-tree PS reference enabled')
