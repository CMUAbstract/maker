# Maker: a build framework and package manager for C code based on GNU Make

Maker can build C applications along with their dependencies.  Dependencies are
libraries that are wrapped into "packages" by conforming to a simple source
tree layout. A packaged library can be used concisely and consistently by
including it into the app repo as a git submodule, listing it as a dependency
in the application makefile:

    DEPS += libbase

and by including it's headers in the source:
   
    #include <libbase/foundation.h>

Maker reads a high-level toolchain-agnostic build specification for an
application or a library from a corresponding makefile.  A build can be made
configurable using variables in makefiles.

Maker can maintain multiple builds of an application (along with its
dependencies), each using a different compiler toolchain.  Currently supported
targets and toolchains are:

| MCU \ Toolchain | TI CL430 compiler | TI MSP430 GCC | LLVM/Clang |
| --------------- | ----------------- | ------------- | ---------- |
| MSP430FR5969    |                 Y |             Y |          Y |
| MSP430F5340     |                   |             Y |          Y |


## Usage: defining the build

TODO: explain what makefiles need to be created and what should go into them.

For now, refer to an example app.


## Usage: build targets

To carry out a particular piece of the build, tell Maker to build a
target with a particular name, by invoking make from the application
root directory. The target name usually includes a hierarchical path, and
sometimes a suffix. For example,

    make bld/gcc/dep

builds the dependencies of the application with the GCC toolchain, and

    make bld/gcc/all

builds the application with the GCC toolchain.

    make bld/gcc/theapp.prog

programs (aka. "flashes") the application onto the MCU.
