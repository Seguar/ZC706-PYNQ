# Physical and image verification

## Test

Physical ZC706 GPIO starter overlay and PYNQ 3.1.2 runtime, before and after a normal Linux reboot. The original failed gate was retained privately; the GPIO-name collision and PS reference-clock assumption were corrected before this repeat gate.

## How

Identity was checked from the running device tree and ARMv7 architecture. Tests used the rebuilt matching bitstream/HWH, the device-tree reference-clock adaptation, a separate authenticated Jupyter kernel, direct GPIO data-register readback rather than the output object's software shadow, and a 1024-word allocated NumPy buffer. LED data/direction were restored; owned kernels and buffers were released.

## Results

- Normal Linux reboot and authenticated Jupyter execution passed.
- Three GPIO addresses/ranges match their HWH; no placeholder addresses remain.
- FCLK0 reports 50.0 MHz using the 33333333 Hz device-tree reference frequency.
- Twelve exact LED-pattern hardware-register readbacks passed across two runs.
- Ten DIP and ten button samples were in their valid ranges.
- Two 1024-word allocation/synchronization/comparison/free tests passed.
- Matching overlay files and the clock adaptation persisted after reboot.

The sanitized primary report and machine-readable results accompany this record. Build timing, DRC, metadata, FIT and offline filesystem checks are recorded in `build-checks.json`.

## Conclusions

The tested installation supports the scoped GPIO-overlay/PYNQ/Jupyter paths. This is not evidence for the full ZC706 feature set or PYNQ-Z1/Z2 peripheral API. Optional entropy and DHCP-server service failures remain documented in the primary report; SSH and Jupyter were active.

## Remaining limits and ways to resolve

The published image is a clean offline build with matching tested kernel/device tree, overlay and clock-code content, not an image of the used lab card. The exact clean downloadable image was **not fresh-flashed and boot-tested**. Perform that test on a spare SD card before relying on unattended deployments; verify the published SHA256 first. First-boot SSH host-key generation was tested with the target ARM executable and systemd unit checks offline.

Clock rates are calculated from device-tree frequency and hardware registers, not externally measured. Inputs were sampled, not manually toggled under observation. LED register readbacks were verified without optical confirmation. HDMI, audio, RFDC, FMC, DMA, PL interrupts and other interfaces are untested or absent from this starter design. No RFSoC board was accessed or programmed.

To repeat the hardware smoke test, run `scripts/verify-board.py` using the board's PYNQ environment and root privileges. It verifies ZC706 identity first, programs the GPIO overlay, performs register/allocator checks and restores LED output state.
