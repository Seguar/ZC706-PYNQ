#!/usr/bin/env python3
"""Physical ZC706 GPIO/allocator smoke test. Loads the GPIO overlay."""
import hashlib
import json
import platform
import xml.etree.ElementTree as ET
from pathlib import Path

assert platform.machine() == 'armv7l', 'Expected ARMv7 ZC706'
assert Path('/proc/device-tree/chosen/pynq_board').read_bytes().rstrip(b'\0') == b'ZC706', 'Wrong board'
import numpy as np
import pynq
from pynq import Clocks, allocate
from pynq.overlays.base import BaseOverlay

expected = {'leds_gpio': 0x41200000, 'switches_gpio': 0x41210000, 'buttons_gpio': 0x41220000}
base = BaseOverlay(download=False)
hwh_path = Path(base.bitfile_name).with_suffix('.hwh')
hwh = ET.parse(hwh_path)
info = hwh.getroot().find('SYSTEMINFO')
assert info.get('DEVICE') == '7z045' and info.get('PACKAGE') == 'ffg900'
for name, address in expected.items():
    ranges = [m for m in hwh.iter('MEMRANGE') if m.get('INSTANCE') == name]
    assert ranges and all(int(m.get('BASEVALUE'), 16) == address for m in ranges)
    assert base.ip_dict[name]['phys_addr'] == address
    assert base.ip_dict[name]['addr_range'] == 65536
base.download()
assert abs(Clocks.fclk0_mhz - 50.0) < 0.05, 'Unexpected calculated FCLK0'
leds = base.leds_gpio
original_data, original_tri = leds.read(0), leds.read(4)
readbacks = []
try:
    leds.channel1.setlength(4)
    leds.channel1.setdirection('out')
    leds.write(4, 0)
    for pattern in (0, 1, 2, 4, 8, 15):
        leds.channel1.write(pattern, 0xf)
        actual = leds.read(0)  # hardware MMIO, not the Output slice's shadow value
        assert actual == pattern, (pattern, actual)
        readbacks.append({'written': pattern, 'hardware_register_read': actual})
finally:
    leds.write(0, original_data)
    leds.write(4, original_tri)
assert leds.read(0) == original_data and leds.read(4) == original_tri
switches = base.switches_gpio.read(0)
buttons = base.buttons_gpio.read(0)
assert 0 <= switches < 16 and 0 <= buttons < 8
buffer = allocate(shape=(1024,), dtype=np.uint32)
try:
    expected_data = np.arange(1024, dtype=np.uint32) ^ np.uint32(0x5a5a5a5a)
    buffer[:] = expected_data
    buffer.sync_to_device()
    buffer.sync_from_device()
    assert np.array_equal(buffer, expected_data)
finally:
    buffer.freebuffer()
print(json.dumps({
    'result': 'PASS', 'board': 'ZC706', 'pynq': pynq.__version__,
    'kernel': platform.release(), 'architecture': platform.machine(),
    'bit_sha256': hashlib.sha256(Path(base.bitfile_name).read_bytes()).hexdigest(),
    'hwh_sha256': hashlib.sha256(hwh_path.read_bytes()).hexdigest(),
    'addresses': expected, 'calculated_fclk0_mhz': Clocks.fclk0_mhz,
    'led_readbacks': readbacks, 'led_state_restored': True,
    'input_samples': {'switches': switches, 'buttons': buttons},
    'allocate_sync_read_free_words': 1024,
    'limits': ['No external clock measurement', 'No physical input actuation test', 'No optical LED measurement']
}, indent=2))
