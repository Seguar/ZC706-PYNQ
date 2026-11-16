# ZC706 PYNQ 3.1.2

Community PYNQ SD-card image and reproducible board-port sources for the AMD/Xilinx ZC706 (XC7Z045-2FFG900).

This port uses PYNQ **3.1.2**, Ubuntu 22.04 (armhf), Linux 6.6.10, and Vivado/Vitis/PetaLinux **2024.1**. PYNQ 4.x removed Zynq-7000 image support; this is not a PYNQ 4.x image.

## Validation status

**Initial community prerelease.** A physical ZC706 passed normal reboot, authenticated Jupyter kernel execution, overlay programming, GPIO register readbacks, and PYNQ allocation with the matching kernel/device tree, overlay files and runtime fix. The separate clean downloadable image has **not** yet had a fresh-flash boot test. Its filesystem, boot metadata, checksums and first-boot SSH-key setup were checked offline. See the exact [test boundary](verification/README.md).

## Download and boot

Download the `.img.xz` and `SHA256SUMS` from [Releases](https://github.com/Seguar/ZC706-PYNQ/releases). Verify the compressed checksum, then flash with a tool that supports XZ, or extract and flash the raw image. Flash the **whole SD card**, not a file copied into its FAT partition. This erases the card.

The image fits a card with at least 7,477,395,456 bytes. A 16 GB or larger card is recommended; nominal 8 GB cards vary. Root storage expands at first boot.

1. Select SD boot on the ZC706, insert the flashed card, and power on.
2. UART: **115200 baud, 8N1**, no flow control.
3. Connect Ethernet to a DHCP-enabled network. Read the assigned address with `ip -4 addr show eth0` over UART.
4. Open `http://<board-IP>:9090`. Default Jupyter password: `xilinx`.
5. SSH: `ssh xilinx@<board-IP>`, default password `xilinx`.

The release hostname is `pynq-2`. `.local` name discovery requires a working mDNS service; it is not guaranteed by this image. Default PYNQ credentials are public; change them after first login. SSH host keys are generated per installation at first boot.

The upstream Ethernet package also configures fallback **192.168.2.99/24**. Keep this isolated from other PYNQ boards using the same address. For a shared lab network, use DHCP and remove that fallback over the verified board's UART if needed; see [network notes](docs/network.md). Do not identify a board solely by the hostname `pynq` or a factory SSH key.

## What is included

The starter overlay contains the PS, AXI GPIO for four LEDs, four DIP switches, and three push buttons. It is not the full PYNQ-Z1/Z2 base overlay: HDMI, audio, MicroBlaze/Pmod, DMA, FMC and other ZC706 interfaces are not implemented or validated here.

```python
from pynq.overlays.base import BaseOverlay
base = BaseOverlay()  # programs the GPIO starter overlay
print(base.ip_dict.keys())
```

The release validation record documents exactly which paths were tested, and which were not. See [verification](verification/README.md).

## Build

See [build instructions](docs/build.md). AMD tools and licenses must be obtained separately; installers, license files, and account credentials are not included.

Sources are under `boards/ZC706/`; matching generated overlay files are distributed as a release asset. The SD image is attached to a GitHub Release, not stored as a giant Git object.

## Important boot fixes

- Export `PYNQ_BOARDNAME=ZC706` **and** `FPGA_MANAGER=1` for every PetaLinux device-tree build. Without the latter, upstream PYNQ selects a legacy AXI interrupt controller at `0x70000000`, absent from this GPIO design. Linux can stall while probing it.
- Use polling-mode zocl with no legacy PL interrupt-controller node.
- Keep explicit UART1 console/early-console arguments.
- Keep GPIO core instance names distinct from external interface names so metadata resolves their AXI addresses.
- Read the Zynq PS reference clock from the device tree (ZC706: 33⅓ MHz), rather than PYNQ’s 50 MHz default.
- Register the static ARM QEMU interpreter with the `F` flag for rootfs builds.

The build checks enforce these device-tree invariants. The bitstream and HWH are generated together with Vivado 2024.1.

## Provenance and licenses

PYNQ v3.1.2 source commit: `3c77124d86bab65ac7bb6beb0aa66e13c83508f2`. Prebuilt inputs and their hashes are recorded in [build inputs](docs/build-inputs.json). This work was prompted by the historical [ZC706-PYNQ port](https://github.com/ussamazahid96/ZC706-PYNQ); its old 2018.3 binaries are not used.

Port sources are BSD-3-Clause. The image contains Ubuntu, Linux, AMD/Xilinx and other third-party packages under their respective licenses; see [third-party notices](THIRD_PARTY.md). This is a community release, not an official AMD image.
