# Source code goes in this subdir
SRC_REL_ROOT = src

# Build artifacts go in this subdir
BLD_REL_ROOT = bld

# Look for external library-type dependencies in this subdir
EXT_REL_ROOT = ext

# Look for external toolchain-type dependencies in this subdir
TOOL_REL_ROOT ?= tools

# Applications for multi-app projects are here
APP_REL_ROOT ?= apps

export SRC_ROOT = $(abspath $(SRC_REL_ROOT))
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

define toolchain-makefile
$(if $(call fileexists,$(TOOL_ROOT)/$(1)/Makefile.target),\
				$(TOOL_ROOT)/$(1)/Makefile.target,\
				$(MAKER_ROOT)/Makefile.$(1))
endef # toolchain-makefile


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
	$$(MAKE) TOOLCHAIN=$(2) -e -C $(1)/$(2) -f $(call toolchain-makefile,$(2)) $$*

endef

define nested-app-rule
$(1)/$(2):
	mkdir -p $(1)/$(2)

# This is a hack, to make the line 'include tools/maker/Makefile' in top-level
# app Makefile work when included from both: a multi-app project and by the
# standalone app build. Because of the latter, we can't use any variables
# (unless we require each app makefile to define those variables). So we
# create a symbolic link, to make that path resolve from the build directrory.
#
# To get this to work on OSX, replace ln -sTf ...  with the following:
#
#	ln -sf $(TOOL_ROOT) $(1)/$(2)/$(TOOL_REL_ROOT)
#
$(1)/$(2)/$(TOOL_REL_ROOT): $(1)/$(2)
	ln -sTf $(TOOL_ROOT) $(1)/$(2)/$(TOOL_REL_ROOT)

$(1)/$(2)/all: $(1)/$(2)/bin ;
$(1)/$(2)/prog : $(1)/$(2)/bin

$(1)/$(2)/%: $(1)/$(2) $(1)/$(2)/$(TOOL_REL_ROOT)
	$$(MAKE) APP=$(3) TOOLCHAIN=$(2) SRC_ROOT=$(abspath $(1)/../$(SRC_REL_ROOT)) -e -C $(1)/$(2) \
		-f ../../Makefile $$*

endef


# Rule for building a tool (which may later be used to build the app)
define nested-tool-rule
$(1)/$(2)/%: $(1)/$(2)
	$$(MAKE) TOOLCHAIN=$(2) -e -C $(1)/$(2) $$*

endef

# Create rules for building the toolchains themselves (referred to as 'tools')
$(foreach tl,$(TOOLS),$(eval $(call nested-tool-rule,$(TOOL_REL_ROOT),$(tl))))

$(TOOL_REL_ROOT)/all/% :  $(foreach tc,$(TOOLS),$(TOOL_REL_ROOT)/$(tc)/%) ;

# Create rules for building/profiling/etc the app using a toolchain
# In multi-app projects, this is needed for bld/<toolchain>/dep target.
$(foreach tc,$(TOOLCHAINS),$(eval $(call nested-rule,$(BLD_REL_ROOT),$(tc))))

$(BLD_REL_ROOT)/all/% : $(foreach tc,$(TOOLCHAINS),$(BLD_REL_ROOT)/$(tc)/%) ;

ifdef APPS

# Create rules for building/profiling/etc the apps using a toolchain,
# for multi-app top-level projects
$(foreach app,$(APPS),\
	$(foreach tc,$(TOOLCHAINS),\
		$(eval $(call nested-app-rule,$(APP_REL_ROOT)/$(app)/$(BLD_REL_ROOT),$(tc),$(app)))))

$(APP_REL_ROOT)/all/%: $(foreach app,$(APPS),$(APP_REL_ROOT)/$(app)/%) ;

# Not sure why the apps/all/% in conjunction with bld/all/% is not working,
# so just define this explicitly
$(APP_REL_ROOT)/all/$(BLD_REL_ROOT)/all/%: \
	$(foreach app,$(APPS),\
		$(foreach tc,$(TOOLCHAINS),$(APP_REL_ROOT)/$(app)/$(BLD_REL_ROOT)/$(tc)/%)) ;

endif # APPS

# When we are including this file as a result of a nested build of an app
ifdef APP
include $(call toolchain-makefile,$(TOOLCHAIN))
endif # APP
