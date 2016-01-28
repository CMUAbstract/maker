export MAKER_ROOT = $(abspath maker)
export LIB_ROOT = $(abspath lib)
export SRC_ROOT = $(abspath src)

BLD_ROOT = bld

include $(MAKER_ROOT)/Makefile.env

# TODO: this stopped working when we started having bld/Makefile
# Shortcut: alias '%' to '%.default'
#%: %.default ;

define nested-rule
%.$(1): $(BLD_ROOT)/%
	make -e -C $(BLD_ROOT)/$$* $(subst default,,$(1))
endef

NESTED_TARGETS = default clean dep depclean flash
$(foreach target,$(NESTED_TARGETS),$(eval $(call nested-rule,$(target))))
