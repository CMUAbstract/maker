BLD_REL_ROOT = bld
EXT_REL_ROOT = ext
SYS_REL_ROOT = systems

export SRC_ROOT = $(abspath src)
export LIB_ROOT = $(abspath $(EXT_REL_ROOT))
export MAKER_ROOT = $(abspath $(EXT_REL_ROOT)/maker)
export SYS_ROOT = $(abspath $(SYS_REL_ROOT))

$(info in maker makefile)

include $(MAKER_ROOT)/Makefile.env

define nested-rule
$(1)/$(2)/%:
	@echo nested [$(MAKE) $(1)/$(2)]
	$$(MAKE) TOOLCHAIN=$(2) -e -C $(1)/$(2) $$*
endef

$(info toolchain $(TOOLCHAINS))

$(foreach tc,$(TOOLCHAINS),$(eval $(call nested-rule,$(BLD_REL_ROOT),$(tc))))
$(foreach lib,$(TOOLS),$(eval $(call nested-rule,$(SYS_REL_ROOT),$(lib))))
#$(foreach lib,$(TOOLS),$(eval $(call nested-rule,$(EXT_REL_ROOT),$(lib))))
