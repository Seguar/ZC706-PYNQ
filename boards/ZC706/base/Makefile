.PHONY: all
all: base.bit base.hwh base.xsa
base.bit base.hwh base.xsa &: build.tcl
	vivado -mode batch -source build.tcl -log vivado.log -journal vivado.jou
