# PYNQ copies this directory into its BSP staging directory.
# ZC706_BOARDDIR is set by the build wrapper.
.PHONY: all
all:
	@test -n "$(ZC706_BOARDDIR)"
	$(MAKE) -C "$(ZC706_BOARDDIR)/base"
	cp "$(ZC706_BOARDDIR)/base/base.xsa" ./base.xsa
