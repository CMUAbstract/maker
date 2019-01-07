# Source code goes in this subdir
SRC_REL_ROOT = src

# Build artifacts go in this subdir
BLD_REL_ROOT = bld

# Install artifacts go in this subdir
INSTALL_REL_ROOT = bin

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
$(1)/$(3):
	mkdir -p $(1)/$(3)

$(2)/$(3):
	mkdir -p $(2)/$(3)

# This is a hack, to make the line 'include tools/maker/Makefile' in top-level
# app Makefile work when included from both: a multi-app project and by the
# standalone app build. Because of the latter, we can't use any variables
# (unless we require each app makefile to define those variables). So we
# create a symbolic link, to make that path resolve from the build directrory.
#
$(1)/$(3)/$(TOOL_REL_ROOT): $(1)/$(3)
	ln -sTf $(TOOL_ROOT) $(1)/$(3)/$(TOOL_REL_ROOT)

$(2)/$(3)/$(TOOL_REL_ROOT): $(2)/$(3)
	ln -sTf $(TOOL_ROOT) $(2)/$(3)/$(TOOL_REL_ROOT)

$(1)/$(3)/all: $(1)/$(3)/bin ;
$(1)/$(3)/prog : $(1)/$(3)/bin

$(2)/$(3)/all: $(1)/$(3)/all $(2)/$(3)/install
	rm $(2)/$(3)/$(TOOL_REL_ROOT)

$(1)/$(3)/%: $(1)/$(3) $(1)/$(3)/$(TOOL_REL_ROOT)
	$$(MAKE) APP=$(4) TOOLCHAIN=$(3) SRC_ROOT=$(abspath $(1)/../$(SRC_REL_ROOT)) -e -C $(1)/$(3) \
		-f ../../Makefile $$*

$(2)/$(3)/%: $(2)/$(3) $(2)/$(3)/$(TOOL_REL_ROOT)
	$$(MAKE) APP=$(4) TOOLCHAIN=$(3) SRC_ROOT=$(abspath $(1)/../$(SRC_REL_ROOT)) \
		BLD_ROOT=$(abspath $(1)/$(3)) -e -C $(2)/$(3) \
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
		$(eval $(call nested-app-rule,$(APP_REL_ROOT)/$(app)/$(BLD_REL_ROOT),\
			$(APP_REL_ROOT)/$(app)/$(INSTALL_REL_ROOT),$(tc),$(app)))))

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
