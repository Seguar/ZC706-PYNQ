# Board console settings must follow the generic PYNQ chosen node.
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append = " file://zc706-console.dtsi"
python do_compile:prepend() {
    import os as zc706_os
    top = zc706_os.path.join(d.getVar("DT_FILES_PATH"), "system-top.dts")
    with open(top) as src:
        contents = src.read()
    if 'zc706-console.dtsi' not in contents:
        with open(top, "a") as dst:
            dst.write('/include/ "zc706-console.dtsi"' + chr(10))
}
