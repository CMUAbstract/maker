
# Build artifacts go in this subdir
BLD_REL_ROOT = bld

# Look for external library-type dependencies in this subdir
EXT_REL_ROOT = ext

# Look for external toolchain-type dependencies in this subdir
TOOL_REL_ROOT ?= $(EXT_REL_ROOT)

export SRC_ROOT = $(abspath src)
export LIB_ROOT = $(abspath $(EXT_REL_ROOT))
export TOOL_ROOT = $(abspath $(TOOL_REL_ROOT))
export MAKER_ROOT = $(abspath $(TOOL_REL_ROOT)/maker)

include $(MAKER_ROOT)/Makefile.util

include $(MAKER_ROOT)/Makefile.env

include $(MAKER_ROOT)/Makefile.device

# Maker doesn't require BOARD, but most app/lib code does, so check
ifeq ($(BOARD),)
$(error Variable not set in app Makefile: BOARD)
endif

# This is for specifying board like so 'boardname:2.0', but we
# can't use it because then the app makefile can't use the BOARD
# and version variables simply (unless we require it include
# a second Makefile from Maker before such usage and after the
# BOARD definition). To keep the interface simple, we don't.
#
# ifneq ($(findstring :,$(BOARD)),)
# BOARD_VERSION := $(lastword $(subst :, ,$(BOARD)))
# BOARD_MAJOR := $(firstword $(subst ., ,$(BOARD_VERSION)))
# ifneq ($(findstring .,$(BOARD_VERSION)),)
# BOARD_MINOR := $(lastword $(subst ., ,$(BOARD_VERSION)))
# endif # has '.'
# endif # has ':'

export BOARDDEFS := \
	-DBOARD_$(call uppercase,$(BOARD)) \
	$(if $(BOARD_MAJOR),-DBOARD_MAJOR=$(BOARD_MAJOR)) \
	$(if $(BOARD_MINOR),-DBOARD_MINOR=$(BOARD_MINOR)) \
	-D__$(call uppercase,$(DEVICE))__ \
	-D__$(FAMILY)__ \
	$(foreach p,$(PERIPHS),-D__$(p)__) \

include $(MAKER_ROOT)/Makefile.binvars-export

export BOARD
export BOARD_MAJOR
export BOARD_MINOR
export DEVICE

# Rule for building the app using a toolchain
# Note: we need to pass TOOLCHAIN on the command line, because bld/Makefile
# is included before Makefile.$(TOOLCHAIN), but we want the var there.
define nested-rule
$(1)/$(2):
	mkdir -p $(1)/$(2)

# Order: first build dependencies, then build the binary
$(1)/$(2)/all: $(1)/$(2)/bin ;
$(1)/$(2)/bin : $(1)/$(2)/dep
$(1)/$(2)/prog : $(1)/$(2)/bin

$(1)/$(2)/%: $(1)/$(2)
	$$(MAKE) TOOLCHAIN=$(2) -e -C $(1)/$(2) \
		-f $(if $(call fileexists,$(LIB_ROOT)/$(2)/Makefile.target),\
				$(LIB_ROOT)/$(2)/Makefile.target,\
				$(MAKER_ROOT)/Makefile.$(2)) $$*

endef

# Rule for building a tool (which may later be used to build the app)
define nested-tool-rule
$(1)/$(2)/%: $(1)/$(2)
	$$(MAKE) TOOLCHAIN=$(2) -e -C $(1)/$(2) $$*

endef

# Create rules for building the toolchains themselves (referred to as 'tools')
$(foreach tl,$(TOOLS),$(eval $(call nested-tool-rule,$(TOOL_REL_ROOT),$(tl))))

# Create rules for building/profiling/etc the app using a toolchain
$(foreach tc,$(TOOLCHAINS),$(eval $(call nested-rule,$(BLD_REL_ROOT),$(tc))))
