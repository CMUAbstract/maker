# Maker: a dependency builder for C code

Maker builds C applications along with their dependencies, similar in purpose
and philosophy to Rust's Cargo and Python's PIP. Maker requires only GNU Make
to run, and is designed to be included itself as a dependency of the app, as an
alternative to installation into the system. Maker relies on Git submodules for
versioning dependencies and for managing their source repositories. There is
no centralized package repository, like PyPI. Instead, a Maker package can come
from any Git repository, as long as it is organized as described below.

A notable feature of Maker is compile-time [configuration of
dependencies](#compile-time-configuration), that is stored in the application
build recipe. For example, application `A` may depend on `libfoo` and enable
HW-accelerated AES in `libfoo`, and application `B` may depend on the same
`libfoo` with HW-accelerated AES disabled. Both A and B will refer to the same
unmodified repository of `libfoo`, and will set configuration flags, exposed by
`libfoo`, in their own build recipes.

An application built with maker must conform to a simple directory layout:

    + appfoo
    + Makefile                 : build recipe that defines the source files to build and configures dependencies
    +--+ src/                  : contains application source files and headers
    +--+ ext/                  : contains dependencies (optionally but usually, included as Git submodules)
       +--+ maker/             : maker itself is a dependency included as a submodule
       +--+ libbar/            : repository with the dependency source code (usually a Git submodule)
       +--+ ...
       +--+ toolchainA/        : some dependencies may be toolchains that are used to build the application
       +--+ toolchainB/
       +--+ ...
    +--+ bld/                   : contains the build artifacts in one subdirectory per toolchain
       +--+ toolchainA/
       +--+ toolchainB/
       +--+ ...

The build recipe in `Makefile` has the following structure:

    EXEC = appfoo
    OBJECTS = main.o srcA.o srcB.o ...
    DEPS += libbar libbaz ...

    # Optinally a dependency may specify the toolchain it should be built with
    # the format `libname:toolchain`, for example
    DEPS += libnolikeclang:gcc

    # Optionally toolchain-specific dependencies can be defined in
    # variables of the form DEPS_toolchain, for example
    DEPS_clang += libfoo

    # Compile-time configuration of dependencies
    export LIBBAR_CONFIGVAR = configvalue
    ...

    # Required boostrap of the Maker build recipies...
    # ... for executables
    include ext/maker/Makefile
    # ... for libraries
    include $(MAKER_ROOT)/Makefile.$(TOOLCHAIN)

An application is built with Maker by invoking [make targets described
below](#usage-build-targets). Maker configuration settings are overridable on
command line when invoking `make CFGVAR=othervalue ...`.

Dependencies
------------

A dependency recognized by Maker is a either

* a *library* to be linked into the application build, or
* a *toolchain*  to be used to build the application (compiler passes, etc.)

To use a [packaged library](#library-dependencies) from an application, add its
repository as a submodule in `ext/`:

    cd ext/ && git submodule add https://github.com/org/libbar

Add the library to the dependency list in application\'s build recipe in `bld/Makefile`:

    DEPS += libbar

or to specify the toolchain that this library must be built if, if different
from the toolchain the app is built, with `lib:toolchain`, for example:

    DEPS += libbar:gcc

Include the library\'s headers from the source:

    #include <libfoo/foo.h>

Builds using different [built-in toolchains](#built-in-toolchains) (e.g. GCC,
Clang) and [custom toolchains](#custom-toolchains) co-exist in separate
subdirectories of the `bld/` directories.

**NOTE**: Having to create this file is annoying, and hopefully it will be
eliminated in the future.

To use a custom toolchain, in addition to the above, the toolchain\'s repo
should be added as a submodule in `ext/`.

## Usage: build targets

Maker is controlled by invoking invoking make from the application
root directory with an argument that identifies the desired target
to build.

To build the application using `toolchainX` will all its library dependencies:

    make bld/toolchainX/all

Sub-targets supported by the [built-in toolchains](#built-in-toolchains) are:

| Sub-target | Action                                                      |
| ---------- | ----------------------------------------------------------- |
| `all`      | build the application along with all of its library dependencies |
| `dep`      | build only the library dependencies |
| `clean`    | remove build artifacts from the application build (not builds of dependencies)|
| `depclean` | remove all build artifacts |
| `prog`     | flash the binary onto the hardware microcontroller (see [details](#flashing)) |

To build a [custom toolchain](#custom-toolchain-dependency):

    make ext/toolchainX/all

The sub-targets usually supported by custom toolchains:

| Sub-target | Action                             |
| ---------- | ---------------------------------- |
|  `all`     | build all components of the toolchain |
|  `llvm`    | build compiler passes for the LLVM framework |
|  `clean`   | clean all components of the toolchain|

Library dependencies
--------------------

To be a Maker package, a library conforms to a simple source tree layout: 

    + libbar/
    + Makefile                  : build recipe for building the library (in the context of an application)
    + Makefile.config           : available compile-time configuration flags and their defaults
    + Makefile.options          : implements the application of the configuration flags from Makefile.config
    +--+ src/                   : contains library source files and headers
       +--+ include/libbar/     : contains public headers
    +--+ bld/                   : build artifacts will go here

**Note**: libraries packaged for Maker are intended to be built in the context
of an application, which will specify the compile-time configuration for the
library. The recipes do not describe how to build the library out-of-context.

The library\'s `Makefile` describes how to build the library in the
context of an application, and is structured as follows:

    LIB = libfoo
    OBJECTS = srcA.o srcB.o ...

    # Required to bootstrap Maker recipies
    include $(MAKER_ROOT)/Makefile.$(TOOLCHAIN)

When desired, it is possible to include sources conditionally, based on
a library configuration flag:

    ifneq ($(LIBFOO_ENABLE_X),1)
    OBJECTS += x.c
    endif

#### Compile-time configuration

The library exposes compile-time configuration to its dependents in
`Makefile.config` and `Makefile.options`.

`Makefile.config` is intended to be read by the library\'s user. It lists the
available parameters and sets their default values and documentation:

    # The X parameter controls how libfoo performs operation Y
    LIBFOO_PARAM_X ?= 1

`Makefile.options` is internal to the library. It applies the options during
the build of the application, usually by defining pre-processor macros.

    ifeq ($(LIBFOO_PARAM_X),1)
    override CFLAGS += -DLIBFOO_PARAM_X
    endif

For providing a convenient interface to the library\'s user, the code that
applies the options may do complex conversions of the parameter from a
high-level representation (e.g. a UART baudrate) to a low-level representation
(e.g.  register settings to get that baudrate).

Maker provides some common useful functions for translating parameters in
`Makefile.pre` (device-independent) and `Makefile.msp` (device-dependent).  For
example, the library can let the user specify pins in `bld/Makefile` in a
`PORT.PIN` format:

    export LIBFOO_TRIGGER = 4.5

by simply applying the parameter using a function provided by Maker:

    include $(MAKER_ROOT)/Maker.pre
    override CFLAGS += $(call gpio_pin,LIBFOO_TRIGGER)

and using `LIBFOO_TRIGGER_PORT` (= 4) and `LIBFOO_TRIGGER_PIN` (= 5) in the
source code.

The parameters are GNU Make variables, so they are basically strings that can
hold any type of value.

Built-in toolchains
-------------------

"Built-in" means that Maker can use the underlying compiler distribution from
the respective upstream, which needs to be installed into the system. The
installation can be done from a Linux distribution package, from pre-build
distributables from the respective websites, or from source as documented
on the respective websites.

| Target | Toolchain | ID | Version | Arch-Linux package | Implementation |
| ------ | --------- | -- | ------- | ------------------ | -------------- |
| MSP430 | [TI GCC](http://ti.com/tool/msp430-gcc-opensource) | gcc   | 5.00.00.00 | `mspgcc-ti` | [Makefile.gcc](Makefile.gcc)   |
| MSP430 | [LLVM/Clang](http://clang.org)                     | clang | 3.8        | `clang`     | [Makefile.clang](Makefile.clang) |

Clang toolchain depends on the TI GCC toolchain, because Clang can only
generate MSP430 assembly, which must then be assembled by GCC.

Maker toolchains only wrap around the above compilation toolchains, with one
exception. Maker includes forked versions of linker scripts from TI GCC, which
add a named section for non-volatile memory region. See `linker-scripts/` for
supported devices, and to add support for others, copy the script from
`msp430-elf/lib/*.ld` in TI GCC installation directory and add `.nv_vars`
section like in this commit c50f2ec4997e23fe9411e6e7f5f28a80392aa83c.

Custom toolchains
-----------------

A toolchain dependency may include various kinds of components (e.g. a compiler
pass, a runtime library, a profiler, etc.) and must include a recipe for how to
use it to build the application. Maker has built-in support for building LLVM
passes (and libraries, see above). Instructions for building any other kind of
components can be specified explicitly in the toolchain's build recipe. A
example toolchain with an LLVM compiler pass would be organized as follows:

    + toolchainX/
    +--+ runtime/               : contains runtime libraries used by toolchainX
       +--+ libx/               : a runtime library libX of toolchainX packaged as described above
       +--+ liby/               : another runtime library
       +--+ ...
    +--+ llvm/                  : contains source files and headers for passes for the LLVM compiler
       +--+ CMakeLists.txt      : LLVM passes are built with CMake
    +--+ Makefile.target        : recipe for how to build the application with toolchainX

Custom toolchains may re-use functionality from a built-in toolchain
`toolchainX` by including `$(MAKER_ROOT)/Makefile.toolchanX` (e.g.
`Makefile.clang`) from their `Makefile.target` recipe.

In `Makefile.target`, custom toolchains may find it useful to use
`DEP_ROOT_libX` and/or `DEP_RELDIR_libX` [configuration
parameters](#maker-configuration-settings) to point to the runtime libraries
(e.g. `libX`), because they won\'t be in `ext/`. For example,

    override DEP_RELDIR_libx = toolchainX/runtime/libx

Maker has built-in support for building the LLVM passes in custom toolchains,
see [build targets](#usage-build-targets).

Maker configuration settings
----------------------------

Some of the Maker features are parametrized, and parameters are set in the
application\'s top-level makefile with `export CFGVAR ?= value` or overriden on
the command line when invoking make: `make CFGVAR=othervalue ...`.

| Parameter    | Description                                                                                         | 
| ------------ | --------------------------------------------------------------------------------------------------- |
| `FET_DEVICE` | Device path to MSP-FET programming device to use by the `bld/*/prog` [target](#usage-build-targets) |
| `VOLTAGE`    | Voltage that MSP-FET is set to by the `bld/*/prog` [target](#usage-build-targets) |
| `DEP_ROOT_libx` | overrides the path to the parent directory of dependency `libx` from the default `ext/` |
| `DEP_RELDIR_libx` | overrides the **sub-path** to the dependency `libx` from the default `libx/` |
| `DEVICE`     | Target MCU model to build for |
| `BOARD`      | Defines a `BOARD_*` macro that the app/lib code can use to identify the target board |
| `BOARD_{MINOR,MAJOR}` | Defines a `BOARD_{MINOR,MAJOR}` macros that the app/lib code can use to identify the target board version |

Flashing functionality
----------------------

Maker includes support for flashing binaries onto MSP430 MCUs using the MSP-FET
hardware, either the [standalone FET device](http://ti.com/tool/msp-fet) or the
built-in FET module on any [MSP430
launchpad](http://www.ti.com/tool/msp-exp430fr5994). The target is `make
bld/toolchain/prog` where `toolchain` identifies a
[built-in](#built-in-toolchains) or [custom toolchain](#custom-toolchains).

The following software must be installed for this to work:

* [mspdebug](https://dlbeer.co.nz/mspdebug/) (for Arch Linux, package
  [`mspdebug`](https://aur.archlinux.org/packages/mspdebug/) on AUR) 
* [TI Debug Stack for MSP430](http://www.ti.com/tool/mspds), aka. `tilib` in
  `mspdebug` (for Arch Linux, package [`mspds`](https://aur.archlinux.org/packages/mspds/) on AUR).
