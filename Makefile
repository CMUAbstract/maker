BLD_REL_ROOT = bld
EXT_REL_ROOT = ext
SYS_REL_ROOT = systems

export SRC_ROOT = $(abspath src)
export LIB_ROOT = $(abspath $(EXT_REL_ROOT))
export MAKER_ROOT = $(abspath $(EXT_REL_ROOT)/maker)
export SYS_ROOT = $(abspath $(SYS_REL_ROOT))
include $(MAKER_ROOT)/Makefile.env

define nested-rule
$(1)/$(2)/%:
	$$(MAKE) TOOLCHAIN=$(2) -e -C $(1)/$(2) $$*
endef

$(foreach tc,$(TOOLCHAINS),$(eval $(call nested-rule,$(SYS_REL_ROOT),$(tc))))
$(foreach lib,$(TOOLS),$(eval $(call nested-rule,$(BLD_REL_ROOT),$(lib))))
