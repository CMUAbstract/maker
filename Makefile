BLD_REL_ROOT = bld
LIB_REL_ROOT = lib

export SRC_ROOT = $(abspath src)
export LIB_ROOT = $(abspath $(LIB_REL_ROOT))
export MAKER_ROOT = $(LIB_ROOT)/maker

include $(MAKER_ROOT)/Makefile.env

define nested-rule
$(1)/$(2).%:
	make -e -C $(1)/$(2) $$*
endef

$(foreach tc,$(TOOLCHAINS),$(eval $(call nested-rule,$(BLD_REL_ROOT),$(tc))))
$(foreach lib,$(LIBRARIES),$(eval $(call nested-rule,$(LIB_REL_ROOT),$(lib))))
