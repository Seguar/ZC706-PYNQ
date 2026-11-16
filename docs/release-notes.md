# PYNQ 3.1.2 for ZC706 — initial community prerelease

Board-port sources, a compressed SD image, matching GPIO overlay files, checksums and a package-version manifest.

The kernel/device tree, rebuilt GPIO overlay and clock adaptation passed physical ZC706 verification before and after normal reboot. Authenticated Jupyter execution, twelve LED register readbacks, input sampling and PYNQ buffer allocation passed. See `verification/` for the sanitized results and limits.

The downloadable image is assembled from a clean offline build, not from the used lab SD card. The exact clean image has not yet been fresh-flashed and boot-tested; this is marked as a prerelease for that reason. Offline FIT/filesystem checks, XZ integrity, target ARM SSH-key generation and runtime-file matching passed.

Assets:

- `ZC706-3.1.2.img.xz` — SD image; extract or use an XZ-aware whole-card imager.
- `SHA256SUMS` — compressed and raw image checksums, plus ancillary assets.
- `ZC706-base-2024.1.zip` — matching `base.bit`, `base.hwh`, Python wrapper.
- `packages.tsv` — versions of packages in the image.

Raw image size: 7,477,395,456 bytes. A 16 GB or larger SD card is recommended; measured nominal 8 GB cards that exceed this byte size also fit. Verify the checksum before flashing. Flashing overwrites the entire card.

Default hostname: `pynq-2`. Ethernet uses DHCP with upstream fallback `192.168.2.99`; isolate or remove the fallback when other PYNQ boards use that address. Jupyter is on port 9090. Factory login/password and Jupyter password are `xilinx`; change them after first login. Each installation generates its own SSH host keys. mDNS is not configured.

GPIO starter only: four LEDs, four DIP switches and three push buttons. Other interfaces are not claimed as supported. AMD 2024.1 tools and licenses must be obtained separately; installers and credentials are not included.
