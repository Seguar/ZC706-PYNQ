# Build the ZC706 image

## Inputs and host

Use an x86-64 Linux build machine with Docker, at least 100 GB free disk (substantially more is useful), and separately licensed/installed Vivado, Vitis and PetaLinux **2024.1**. The supplied Dockerfile comes from pinned PYNQ v3.1.2 and uses Ubuntu 22.04. AMD tools remain outside the container and are mounted read-only. This port does not require or modify a newer tool installation.

```sh
git clone https://github.com/Seguar/ZC706-PYNQ.git
cd ZC706-PYNQ
./scripts/prepare.sh
./scripts/build.sh
```

Defaults assume settings scripts at `/tools/Xilinx/Vivado/2024.1/settings64.sh`, `/tools/Xilinx/Vitis/2024.1/settings64.sh`, and `/tools/petalinux/2024.1/settings.sh`; adjust `TOOLS_ROOT`, `VIVADO_SETTINGS`, `VITIS_SETTINGS`, `PETALINUX_SETTINGS`, `LICENSE_DIR`, or `BUILD_DIR` as needed. Tool paths must be under the mounted tool root. AMD tools and the tool-root paths must not contain spaces for this build flow. The build machine needs working headless tool licensing and Zynq-7000 device support.

`prepare.sh` pins the PYNQ commit, verifies the public ARM rootfs/SDIST hashes, and builds the upstream Docker environment. This pins the main inputs but is not a claim of bit-for-bit reproducibility: upstream package repositories and PYNQ dependency clones can change.

The wrapper also pins the PYNQ-Metadata and PYNQ-Utils dependency commits used by the release.

The external board port builds the GPIO design, imports its XSA, and runs PYNQ SD build. Expected output: `work/PYNQ/sdbuild/output/ZC706-3.1.2.img`. The bitstream, HWH, XSA, timing and DRC reports are generated under `boards/ZC706/base/` and excluded from Git. Do not mix files from different hardware runs.

## Host compatibility

On hosts where AppArmor blocks BitBake user namespaces, install the supplied scoped profile as an administrator, then set `APPARMOR_PROFILE=zc706-pynq-build` when invoking `build.sh`. For example:

```sh
sudo install -m 0644 scripts/zc706-pynq-build.apparmor /etc/apparmor.d/zc706-pynq-build
sudo apparmor_parser -r /etc/apparmor.d/zc706-pynq-build
APPARMOR_PROFILE=zc706-pynq-build ./scripts/build.sh
```

This grants the dedicated build container user-namespace access; it does not require disabling host AppArmor globally. Prefer the supported Ubuntu 22.04 host when possible. Some newer hosts lack the genuine `libtinfo.so.5` required by Vivado 2024.1; install the appropriate compatibility library rather than aliasing ABI 6 to ABI 5.

`setup-arm-binfmt.sh` registers the static ARM QEMU interpreter with the `F` flag inside the privileged build container. This avoids ARM chroot `Exec format error` failures.

## Device-tree cache

The PYNQ recipe reads `PYNQ_BOARDNAME` and `FPGA_MANAGER` through `BB_ORIGENV`, excluded from normal task signatures. The wrapper exports **both** on every invocation. If reusing a tree built with the wrong settings, run `REBUILD_DTB=1 ./scripts/build.sh` to clean the device-tree task cache and rebuild it. Never accept a DT with `/axi/interrupt-controller@70000000` for this hardware design.

The board-specific recipe appends explicit UART1 console settings. GPIO IP cores use names distinct from external ports; the `zc706_compat` stage configures PYNQ to read the PS reference frequency from the device tree instead of assuming 50 MHz. The final FIT gate checks board identity, 1 GiB memory, Ethernet PHY 7 and handle, UART, polling-mode zocl, and absence of the legacy PL controller.

## SD capacity and release packaging

The original WIC image was slightly larger than a measured nominal 8 GB card. The release uses an offline, checked ext4 shrink: root filesystem 1,792,000 blocks of 4096 bytes (7000 MiB), root partition start sector 268288, root partition length 14336000 sectors, total 7477395456 bytes. Only use these sizes after checking the generated layout and `resize2fs -P`; do not truncate a filesystem before shrinking it.

The release is packaged from the clean offline build image, not from the lab-used SD card. The included `zc706_defaults` package removes inherited SSH host keys and generates fresh keys before SSH starts. License notices stay in the image. Use `xz -T4 -1 -k image.img`, and publish both compressed/raw SHA256 values. Images belong in GitHub Releases rather than Git history.
