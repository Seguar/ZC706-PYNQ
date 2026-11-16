# Third-party components

The board port is built on [PYNQ v3.1.2](https://github.com/Xilinx/PYNQ/tree/v3.1.2), BSD-3-Clause; its notice is retained in `licenses/PYNQ-LICENSE`.

The SD image also includes Ubuntu packages, the AMD/Xilinx Linux kernel (GPL-2.0), U-Boot (GPL-2.0+), XRT/zocl, Python packages, and generated FPGA hardware. Each retains its own copyright and license. Ubuntu notices and license texts are available under `/usr/share/doc` in the image. PYNQ license files remain in the installed source tree. AMD installers, SDK installations, private account files, license keys, and vendor tool binaries are not release assets.

Source locations and the exact PYNQ input revision are recorded in `docs/build-inputs.json` and `docs/build.md`. The PetaLinux 2024.1 build resolves the corresponding kernel, U-Boot and XRT sources using the pinned PYNQ build recipes; retain their source downloads when redistributing modified packages. Ubuntu source packages are available from the Ubuntu archive using the installed package version.

- PYNQ: https://github.com/Xilinx/PYNQ
- Linux: https://github.com/Xilinx/linux-xlnx
- U-Boot: https://github.com/Xilinx/u-boot-xlnx
- XRT: https://github.com/Xilinx/XRT
- Ubuntu: https://archive.ubuntu.com/ubuntu/

Upstream license notices are not replaced by the port's license. The historical ZC706 repository is acknowledged as inspiration; no historical prebuilt bitstream is used.
