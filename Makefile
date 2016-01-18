export MAKER_ROOT = $(abspath maker)
export LIB_ROOT = $(abspath lib)
export SRC_ROOT = $(abspath src)

BLD_ROOT = bld

# Shortcut: alias '%' to '%.default'
%: %.default ;

define nested-rule
%.$(1): $(BLD_ROOT)/%
	make -e -C $(BLD_ROOT)/$$* $(subst default,,$(1))
endef

NESTED_TARGETS = default clean dep depclean
$(foreach target,$(NESTED_TARGETS),$(eval $(call nested-rule,$(target))))
