ZC706 runtime v2 release functional gate - PASS

Test: Repeat full basic PYNQ functional gate after installing the verified hardware rebuild and guarded clock model fix. Previous FAIL evidence is preserved.

How: Dedicated UART adapter and ZC706 identity guard, numeric-address SSH/ARP/UART comparison, payload hashes, installed-path resolution, backup, pre-download metadata check, actual FPGA programming, authenticated Jupyter kernels, and normal Linux reboot followed by a fresh full gate.

Results: Both completed gates PASS. New GPIO cores map to 0x41200000 / 0x41210000 / 0x41220000, each range 65536, matching the HWH. No placeholder address used. Clock reference 33333333 Hz from DT; PYNQ FCLK0 reports 50.0 MHz (software-calculated, no external instrument). Six LED patterns 0,1,2,4,8,15 each read back exactly through the GPIO data register per run. Original LED data and direction restored in finally blocks. Five DIP and five button input samples per run were all zero and valid; inputs never driven. Each run allocated 1024 uint32 words, verified sequence after both synchronization calls, and freed the buffer. Jupyter math sum=45 and identity checks passed. All 3 owned kernels deleted (HTTP 204); existing count was zero. Initial output-channel read API exception preserved; corrected only test register-read usage, then repeated full gate.

Normal boot: Normal sudo reboot captured through Linux and services without autoboot intervention or RAM device-tree changes. Fresh postboot kernel repeated FPGA programming, address, clock, GPIO, restore and allocation checks. Runtime file hashes and clock marker persisted. UART closed; buffers freed. Optional haveged SIGSYS and DHCP server subnet failures remain documented; no services modified to obtain PASS. Existing zocl polling/IRQ warning does not block allocation and provides no interrupt proof.

Hashes: base.bit 8d5f9fe850b08fb728ce9238ded6c65bc59306873051d1405fe197bd74b86a71; base.hwh 439ced3296f2f8ebbb710898fa4d0661a5bebbf8bc00a1e42dffdd033de63730. Guarded ps.py reads device-tree PS reference unless explicit reference is supplied; missing-node fallback remains 50 MHz. Backup preserved before install; patch anchor checked once and idempotence asserted.

Conclusions: Installed SD runtime passes this basic release functional gate after normal reboot. This does not verify the separately prepared public image. No physical LED observation, human input actuation, RFDC, FMC, HDMI, DMA or interrupt operation was proven.

Ways to resolve remaining limits: Parent must use exact verified payload and clock patch in its image and retain the image-build boundary. Optional service failures can be addressed separately. No publishing or git operations performed.
