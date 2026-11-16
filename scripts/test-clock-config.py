#!/usr/bin/env python3
"""Exercise the reference-clock selection without FPGA/MMIO access."""
import ast
import importlib.util
from pathlib import Path
from unittest.mock import patch

module_path = Path(__file__).with_name('configure-pynq-clock.py')
spec = importlib.util.spec_from_file_location('clock_patch', module_path)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
source = 'class Clock:\n    DEFAULT_SRC_CLK_MHZ = 50.0\n' + module.REPLACEMENT
namespace = {}
exec(compile(source, str(module_path), 'exec'), namespace)
clock = namespace['Clock']
for hz, expected in ((33333333, 33.333333), (50000000, 50.0)):
    with patch('pathlib.Path.read_bytes', return_value=hz.to_bytes(4, 'big')):
        assert clock()._ref_clk_mhz == expected
with patch('pathlib.Path.read_bytes', side_effect=FileNotFoundError):
    assert clock()._ref_clk_mhz == 50.0
with patch('pathlib.Path.read_bytes', side_effect=AssertionError('Must not read DT')):
    assert clock(ref_clk_mhz=25)._ref_clk_mhz == 25
for raw in (b'', b'\0', bytes(4), (200000000).to_bytes(4, 'big')):
    with patch('pathlib.Path.read_bytes', return_value=raw):
        try:
            clock()
        except ValueError:
            pass
        else:
            raise AssertionError('Invalid clock accepted')
print('PASS: ZC706/Zynq reference selection, override, fallback, invalid data')
