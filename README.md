# SIRF-SuperBuild

[![gh-action-badge]][gh-action-link] [![CI-badge]][CI-link] [![style-badge]][style-link] [![docker-badge]][docker-link]
![install-badge] [![zenodo-badge]][zenodo-link]

The SIRF-SuperBuild can download/build/install [SIRF] and its dependencies (including Gadgetron and other packages useful for PET/MR data processing).

[SIRF]: https://github.com/SyneRBI/SIRF

The SuperBuild can:

- [build & run docker containers](docker/README.md): the easiest way
- [build & run a VirtualBox VM](VirtualBox/README.md): used to build [SIRF VM](https://zenodo.org/doi/10.5281/zenodo.3228198)
- [launch cloud instances on Azure via TerraForm](cloud/terraform/azure/README.md): probably outdated
- [build & run manually using CMake](#building-and-running-sirf-manually): see instructions below

## Contents

- [Running SIRF with Docker](#running-sirf-with-docker)
- [Running SIRF with VirtualBox](#running-sirf-with-virtualbox)
- [Building and Running SIRF manually](#building-and-running-sirf-manually)
  - [Dependencies](#dependencies)
  - [Create the SuperBuild directory](#create-the-superbuild-directory)
  - [Install CMake](#install-cmake)
  - [Clone the SIRF-SuperBuild project](#clone-the-sirf-superbuild-project)
  - [Build and Install](#build-and-install)
  - [Set Environment variables](#set-environment-variables)
  - [Open a terminal and start Gadgetron](#open-a-terminal-and-start-gadgetron)
  - [Testing](#testing)
  - [Running examples](#running-examples)
- [OS specific information](#os-specific-information)
  - [Installation instructions for Ubuntu](#Ubuntu-install)
  - [Installation instructions for Mac OS](#OSX-install)
- [Advanced installation](#advanced-installation)
  - [Optional libraries](#optional-libraries)
  - [use a different compiler than the system default](#use-a-different-compiler-than-the-system-default)
  - [Compiling against your own packages](#Compiling-packages)
  - [Python installation location](#python-installation-location)
  - [Building with specific versions of dependencies](#building-with-specific-versions-of-dependencies)
  - [Building from your own source](#building-from-your-own-source)
  - [Building with Intel Math Kernel Library](#building-with-intel-math-kernel-library)
  - [Building CCPi CIL](#building-ccpi-cil)
  - [Passing CMAKE arguments to specific projects](#passing-cmake-arguments-to-specific-projects)
  - [Building with CUDA](#building-with-cuda)
- [FAQs](#faqs)

## Running SIRF with Docker

> [!TIP]
> The easiest way to run [SIRF] & all its dependencies is to use Docker.

For running (or even building) docker containers, see [`docker/README.md`](docker/README.md).

## Running SIRF with VirtualBox

See [`VirtualBox/README.md`](VirtualBox/README.md).

## Building and Running SIRF manually

### Dependencies

The SuperBuild depends on CMake >= 3.16.2 on Linux and 3.20 on Windows.

> [!NOTE]
> A few dependencies are not installed by the SuperBuild; see [operating system information](#os-specific-information).

If you are building Gadgetron there are a series of [additional dependencies](https://github.com/gadgetron/gadgetron/wiki/List-of-Dependencies), which must be met.

To compile and install SIRF with the SuperBuild follow these steps:

### Create the SuperBuild directory

We will assume in these instructions that you want to install the software in `~/devel'. You
can of course decide to put it elsewhere. Let's create it first.

```sh
mkdir ~/devel
```

### Install CMake

If you do not have CMake >= 3.16.2 on Linux and 3.20 on Windows, install it first. We suggest to follow the [official CMake instructions](https://cmake.org/download).

If you use a CMake installer, you will be asked to read and accept CMake's license. If you answered the last question during the CMake installation with yes, then on Linux you should use

```sh
export PATH="/usr/local/cmake/bin:$PATH"
```

Change `/usr/local/` to your chosen installation path (if different).

> [!TIP]
> You might want to add the `PATH` line to your start-up file e.g. `.profile`, `.bashrc` or `.cshrc`.

<!-- <br/> -->

> [!WARNING]
> `export` statements won't work if you are running `csh`. The equivalent would be:
>
> ```csh
> set path = ( /usr/local/cmake/bin $path )
> ```

### Clone the SIRF-SuperBuild project

```sh
cd ~/devel
git clone https://github.com/SyneRBI/SIRF-SuperBuild
```

### Build and Install

Create a build directory and configure the software.


```sh
cmake -S ./SIRF-SuperBuild -B ./build
```

You can of course use the GUI version of CMake (called `cmake-gui` on Linux/OSX), or the
terminal version `ccmake` to check and set various variables. See the [CMake tutorial on how to run CMake](https://cmake.org/cmake/help/latest/guide/tutorial).

By default, this will select stable configurations of the various projects. See [the advanced installation section](#advanced-installation).

Then use your build environment to build and install the project. On Linux/OSX etc, you would normally use

```sh
cmake --build ./build --parallel N
# alternatively: sudo cmake --build ./build --parallel N
```

where `N` are the number of cores you want to use for the compilation. You will only need the `sudo` command if you set `CMAKE_INSTALL_PREFIX` to a system folder (e.g., `/usr/local`). Note that the default location is `<your-build>/INSTALL`.

For Eclipse/XCode/Visual Studio, you could open the project, or build from the command line

```sh
cmake --build ./build --config Release
```

Note that there is no separate install step.

### Set Environment variables

Source a script with the environment variables appropriate for your shell

For instance, assuming that you set `CMAKE_INSTALL_PREFIX=~/devel/INSTALL` (for `sh`/`bash`/`ksh` etc.):

```sh
source ~/devel/INSTALL/bin/env_sirf.sh
```

You probably want to add a similar line to your `.bashrc`/`.profile`.

Or for csh

```csh
source ~/devel/INSTALL/bin/env_sirf.csh
```

You probably want to add a similar line to your `.cshrc`.

Notice that for backwards compatibility a symbolic link to `env_sirf.sh` with the name `env_ccppetmr.sh` will be created, and similarly for the `csh`.

### Open a terminal and start Gadgetron

To be able to use Gadgetron, a Gadgetron server must be running. You can do this by opening a new terminal window and enter:

```sh
gadgetron
```

N.B.: If you didn't add any of the above statements to your `.bashrc` or `.cshrc`, you will have to source `env_sirf.*` again in this terminal first.

### Testing

Tests for most SuperBuild projects can be en/disabled projects when configuring the build.
After setting the environment variables and starting Gadgetron, you can run tests as:

```sh
cd ~/devel/build
ctest --verbose
```

Typical output will be something like

```
test 1
    Start 1: SIRF_TESTS

1: Test command: /usr/local/bin/ctest "test"
1: Test timeout computed to be: 9.99988e+06
1: Test project /home/sirfuser/devel/SIRF-SuperBuild/SIRF-prefix/src/SIRF-build
1:     Start 1: PET_TEST1
1: 1/3 Test #1: PET_TEST1 ........................   Passed    2.94 sec
1:     Start 2: MR_FULLY_SAMPLED
1: 2/3 Test #2: MR_FULLY_SAMPLED .................   Passed    3.83 sec
1:     Start 3: MR_UNDER_SAMPLED
1: 3/3 Test #3: MR_UNDER_SAMPLED .................   Passed    2.93 sec
1:
1: 100% tests passed, 0 tests failed out of 3
1:
1: Total Test time (real) =   9.70 sec
1/1 Test #1: SIRF_TESTS .......................   Passed    9.70 sec

100% tests passed, 0 tests failed out of 1

Total Test time (real) =   9.70 sec
```

The user may also run the SIRF tests independently of the SuperBuild. Just enter the SIRF build directory and launch `ctest`:

```sh
cd ~/devel/build/builds/SIRF/build
ctest --verbose
```

If you see failures, you might not have followed the above steps correctly, or have some missing Python modules.

### Running examples

Examples are installed in `$SIRF_PATH/examples`. See [our related Wiki page](https://github.com/SyneRBI/SIRF/wiki/Examples) for more information.

## OS specific information

### Installation instructions for Ubuntu<a name="Ubuntu-install"></a>

They can be found [here](https://github.com/SyneRBI/SIRF/wiki/SIRF-SuperBuild-Ubuntu)

### Installation instructions for Mac OS<a name="OSX-install"></a>

They can be found [here](https://github.com/SyneRBI/SIRF/wiki/SIRF-SuperBuild-on-MacOS)

## Advanced installation

## Optional libraries

STIR can use other libraries to add extra IO capabilities. At present, the SuperBuild supports the following:

- ITK: the [Insight Toolkit](https://itk.org). STIR will use this to read in images in file formats supported by ITK,
including DICOM, Nifty, MetaIO, NRRD.
- ROOT: the [CERN framework for data handling](https://root.cern.ch). STIR will use this to read ROOT files produced
by Open GATE, the Monte Carlo simulator.

Each of these has 2 CMake variables. For example, for ITK:

- `USE_ITK`: enable ITK support
- `USE_SYSTEM_ITK` (defaults `OFF`): if `USE_ITK=ON` and `USE_SYSTEM_ITK=ON`, do not build ITK, but let CMake find it on your system. If it cannot, you can set `ITK_DIR` to the path where `ITKConfig.cmake` was installed. See also [this section](#Compiling-packages).

Currently, `USE_ITK` defaults to `ON` and `USE_ROOT` defaults to `OFF`.

Each of these projects has many CMake variables when you build it directly. In this SuperBuild, we set them to build a minimal (?) set of libraries sufficient for STIR support.
You can enable more features by using other CMake variables (e.g. `ROOT_X11` defaults to `OFF`), but see also [this section](#passing-cmake-arguments-to-specific-projects).

> [!WARNING]
> - ROOT insert its own error handler for when a program crashes, which at first sight claims that there is a problem with ROOT. More than likely however, the problem is elsewhere. The stack trace printed on the console might help.
> - Building these libraries takes quite a long time. You could try to install them in other ways, but might encounter problems then. Let us know if that is the case.

## Use a different compiler than the system default

You can tell CMake to use a different compiler than what it finds by default. You will need to specify both C and C++ compilers. For instance, to use `gcc-11`, use

```sh
CC=gcc-11
CXX=g++-11
export CC CXX
ccmake normal-options
```

This needs to be done the **very first time** you run CMake for that build.

### Compiling against your own packages<a name="Compiling-packages"></a>

SIRF depends on many packages. By default, these packages are installed by the SuperBuild. However, the user can decide to compile SIRF against their own versions of certain packages. This can be done via the `USE_SYSTEM_*` options in `CMake`. For example, if you wish to compile SIRF against a version of Boost that is already on your machine, you could set `USE_SYSTEM_BOOST` to `ON`.

This `USE_SYSTEM_*` function can be used for as many or as few packages as desired. Advantages to building against your own version of certain packages are decreased compilation times and the potential to use newer versions of these packages.

However, we have only tested SIRF with the versions of the required dependencies that are built by default in the SuperBuild. If you decide to compile SIRF using system versions of the dependencies, you run a greater risk of something going wrong.

For this reason, we advise new SIRF users to compile with all the `USE_SYSTEM_*` options disabled. If you decide to use system versions of certain packages, we would be interested to hear about it any compatibility issues that you may run into.

### Python installation location

By default, Python executables and libraries are installed under `CMAKE_INSTALL_PREFIX/python`. If you wish for them to be installed elsewhere, you can set the `PYTHON_DEST` CMake variable.

Alternatively, you simply cut and paste these folders to their desired locations. In this case, you would then need to ensure
that `PYTHONPATH` is updated accordingly. This is because the sourced `env_sirf.*` will point to the original (old) location.

### Package specific information

For default versions built, see [version_config.cmake](version_config.cmake) and
[below on how to change them](#building-with-specific-versions-of-dependencies).

The SuperBuild allows building many packages and sets dependencies correctly. However, the
emphasis is on building SIRF. Its dependent packages are therefore by default built in a
minimal configuration. We provide some CMake variables to change that behaviour, and also
set some main options of some packages. Most of these are "advanced" CMake options so as not to
confuse the new user. Naming of these options is generally the same as in the original package
but prefixed. We list main examples here, but you can check with CMake (or the `External*.cmake` files).
(See [below](#passing-cmake-arguments-to-specific-projects) for information
on how to set other options).

#### STIR

- `STIR_BUILD_EXECUTABLES` defaults to `OFF`
- `STIR_BUILD_SWIG_PYTHON` defaults to `ON`, meaning that the STIR Python interface will be built, i.e. you can use STIR's Python interface as well as the SIRF Python interface to STIR.
- `STIR_DISABLE_LLN_MATRIX` defaults to `ON`, you might want to set this to `OFF` if you have GATE and use its output to ECAT sinograms (although this is not recommended).
- `STIR_ENABLE_EXPERIMENTAL` defaults to `OFF`

#### ITK

- `ITK_MINIMAL_LIBS` defaults to `ON`. For the list of modules (concentrated on IO) built, check [External_ITK.cmake](SuperBuild/External_ITK.cmake).
- `ITK_USE_SYSTEM_HDF5` defaults to `ON`, i.e. tell ITK to use same HDF5 library as other software built here. Note that this would normally be the HDF5 version built by the SuperBuild. Set this variables `OFF` if ITK has problems with HDF5.

### Building with specific versions of dependencies

By default, the SuperBuild will build the latest stable release of SIRF and associated versions of the dependencies. However, the SuperBuild allows the user to change the versions of the projects it's building. The current default values can be found in [version_config.cmake](version_config.cmake).

There is a `DEVEL_BUILD` tag that allows to build the upstream/master versions of most packages (`DEVEL_BUILD=ON`).

One may want to use only a specific version of a package. This is achieved by adding the right tag to the command line:

```sh
cmake -S ./SIRF-SuperBuild -B ./build -DSIRF_TAG=<a valid hash>
```

To use the `DEVEL_BUILD` option one may (on the terminal)

```sh
cmake -S ./SIRF-SuperBuild -B ./build -DDEVEL_BUILD=ON -U*_TAG -U*_URL
```

The `-U` flags will make sure that cached CMake variables are removed such that `DEVEL_BUILD=ON` will
set them to the desired versions.

Note that the CMake `*_TAG` and `*URL` options are Advanced Options. When running the CMake GUI (or ccmake) they will therefore only be visible when you toggle those on.

### Building from your own source

When developing, you might have a project already checked-out and let the SuperBuild use that. In this case,
you probably also want to disable any `git` processing. You can achieve this by (using SIRF as an example)

```sh
cmake -S ./SIRF-SuperBuild -B ./build -DDISABLE_GIT_CHECKOUT_SIRF=ON -DSIRF_SOURCE_DIR=~/wherever/SIRF
```

### Building with Intel Math Kernel Library

[Gadgetron](https://github.com/SyneRBI/SIRF/wiki/SIRF,-Gadgetron-and-MKL) and Armadillo can make use of Intel's Math Kernel Library.

1. Install Intel MKL following the instructions at [their](https://software.intel.com/en-us/mkl) website. For debian based linux follow [this link](https://software.intel.com/en-us/articles/installing-intel-free-libs-and-python-apt-repo). The latter will install MKL in `opt/intel`
2. Gadgetron's [FindMKL.cmake](https://github.com/gadgetron/gadgetron/blob/master/cmake/FindMKL.cmake#L23) will try to look for MKL libraries in `/opt/intel` on Unix/Apple and in `C:/Program Files (x86)/Intel/Composer XE` in Windows. Make sure that this is the location of the library or pass the variable `MKLROOT_PATH` (Unix/Apple) or set the environment variable `MKLROOT_PATH` on Windows.
3. Configure the SuperBuild to pass `Gadgetron_USE_MKL=ON`.

Notice that other packages may look for a blas implementation issuing CMake's [`find_package(BLAS)`](https://github.com/Kitware/CMake/blob/master/Modules/FindBLAS.cmake#L142L148). This will look for MKL taking hint directories from the environment variable `LD_LIBRARY_PATH`, `DYLD_LIBRARY_PATH` and `LIB`, on Unix, Apple and Windows respectively.

### Building CCPi CIL

The [CCPi Core Imaging Library (CIL)](https://www.ccpi.ac.uk/CIL) in included in the SuperBuild. The functionality of `CIL` can be expanded by plugins. Currently included by default are:

- [`CCPi-Regularisation`](https://github.com/TomographicImaging/CCPi-Regularisation-Toolkit)
- [`TomoPhantom`](https://github.com/dkazanc/TomoPhantom)
- [IPP](https://www.intel.com/content/www/us/en/developer/tools/oneapi/ipp.html#gs.dnfk5r) support for optimised [FBP/FDK](https://github.com/TomographicImaging/CIL#dependency)
- (requires CUDA) [ASTRA-toolbox](https://github.com/astra-toolbox/astra-toolbox) for CT reconstruction

Optional dependencies include:

- (requires CUDA) [`TIGRE`](https://github.com/CERN/TIGRE)

### Passing CMake arguments to specific projects

You may want to change the CMAKE arguments used to build some of the projects. You can pass those flags directly to the SuperBuild CMAKE with a semicolon-separated list, using the following notation:

```sh
cmake -S ./SIRF-SuperBuild -B ./build -D${proj}_EXTRA_CMAKE_ARGS:STRING="-Dflag1:BOOL=ON;-Dflag2:STRING=\"your_string\""
```

All the flags from the following projects can be set using this technique:

- ITK
- ROOT
- STIR
- Gadgetron
- SIRF
- NIFTYREG
- NiftyPET
- CCPi-Regularisation-Toolkit
- TomoPhantom

As an example, the following changes some Gadgetron and NiftyReg flags

```sh
cmake -S ./SIRF-SuperBuild -B ./build -DGadgetron_EXTRA_CMAKE_ARGS:STRING="-DBUILD_PYTHON_SUPPORT:BOOL=ON;" -DNIFTYREG_EXTRA_CMAKE_ARGS:STRING="-DCUDA_FAST_MATH:BOOL=OFF;-DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF"
```

### Building with CUDA

Some dependencies like Gadgetron, NiftyPET and Parallelproj require building parts of their code base with CUDA. It has been found that version [10.1 update 1](https://github.com/gadgetron/gadgetron/issues/792#issuecomment-786481256) works, but following updates of 10.1 and 10.2 do not build Gadgetron. It is reported that version CUDA toolkit version 11 works. We have not tested lower versions of the toolkit yet.

Note that if you want to use the `clang` compiler and CUDA, you likely will have to set the `CUDAHOSTCXX` environment variable (before calling CMake), see also [`CMAKE_CUDA_HOST_COMPILER`](https://cmake.org/cmake/help/latest/variable/CMAKE_CUDA_HOST_COMPILER.html).

## FAQs

### MATLAB support

Previous versions of SIRF had a MATLAB interface. This is now outdated and probably broken. If you want to try it anyway, check our [SIRF and MATLAB page](https://github.com/SyneRBI/SIRF/wiki/SIRF-and-MATLAB).

### FFTW3 issues

As CMake doesn't come with FFTW3 support, it is currently necessary to have `FindFFTW3.cmake` reproduced 3 times. sigh.

If you want to use your own FFTW3 library but it is not in a standard location, you have to set an environment variable `FFTW3_ROOT_DIR` before running CMake.
This is poorly documented in `FindFFTW3.cmake`, which could be fixed by a PR to Gadgetron, ISMRMRD and SIRF. (Note that @KrisThielemans has tried to use `set(ENV{FFTW3_ROOT_DIR} some/location)` in our `External_FindFFTW.cmake`. This however doesn't pass the environment variable to the CMake instances for Gadgetron etc.)

By the way, if you build with `USE_SYSTEM_FFTW3=OFF` (the default except on Windows), the  `FFTW3_ROOT_DIR` env variable is ignored (as find_library etc give precedence to `CMAKE_PREFIX_PATH` over `HINTS` ).

### Armadillo issues

CMake does come with `FindArmadillo.cmake` but it currently (at least up to CMake 3.12) has no variable to specify its location at all. This implies that when using `USE_SYSTEM_ARMADILLO=On`, you have to install armadillo in a system location, unless some extra work is done. See [this post on stackoverflow](https://stackoverflow.com/questions/35304513/cmake-find-armadillo-library-installed-in-a-custom-location) for some suggestions, which we haven't tried.

[gh-action-badge]: https://github.com/SyneRBI/SIRF-SuperBuild/actions/workflows/c-cpp.yml/badge.svg
[gh-action-link]: https://github.com/SyneRBI/SIRF-SuperBuild/actions/workflows/c-cpp.yml
[CI-badge]: https://github.com/SyneRBI/SIRF-SuperBuild/actions/workflows/docker.yml/badge.svg
[CI-link]: https://github.com/SyneRBI/SIRF-SuperBuild/actions/workflows/docker.yml
[style-badge]: https://api.codacy.com/project/badge/Grade/eefea1a2f11148fabd9a4ec9b822701f
[style-link]: https://www.codacy.com/gh/SyneRBI/SIRF-SuperBuild?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=SyneRBI/SIRF-SuperBuild&amp;utm_campaign=Badge_Grade
[docker-badge]: https://img.shields.io/docker/pulls/synerbi/sirf.svg
[docker-link]: https://hub.docker.com/r/synerbi/sirf
[install-badge]: https://img.shields.io/badge/dynamic/json.svg?label=users&uri=https%3A//raw.githubusercontent.com/ccp-petmr-codebot/github-stats/SyneRBI/SIRF-SuperBuild/SyneRBI_SIRF_SuperBuild.json&query=total&colorB=8000f0&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAD0ElEQVR4nMSXS2ic5RfGf5lL/pPMZP7JjB0ba53axkvRegGhpFaxVkqjOxetoi6UUjG4ELdVFy50I6gLtfUCFilUiwheilZXIm1FiZSCpYmYRppoUpvRJONMOpmJnOT54DBtxk4CmQPDl/d85z3vc55zeb%2BEWJr0AE8uxcFSAWwE7mwkgE7gqkYCWAGkGwkgBVQaCSACFBsJwPaXgGijAJhMAonlAvAc0OHWlv8pB8BS8hLQtFhAtaRFdD%2BodQz4BngbuEm624BZ4MYFfFwUcD0MdAGjeqKojf4Jx8B1wAhwwwI%2BLuqYegBkgePAKq2Tot9AtEln744Bay7XaS0Are4wk6uBPmCl1gkByDsGMrLx%2B1L61Q3gBeBTt7axe9I5C1LgGcjIxo/nvcC%2BhQ6J1ACwWREmlWeLfNBVeELR5x0AA/czcKXzE6SjSQV6SQbiwLdAt9bNMu5zFZ5REXoAU6F5u4TTjcgfAvI78AuwVrprge%2BB1R7Aw0Leq7VV82mgX3%2BbXAGcd1G0J0Ik18foSoVply4MFFyA64ABpSUI5HEFNndW5NEo2c9LPNQT5fkS7IxBdqDCXRUY6wpxtgKZKGS/KNH6QJTV09D3P1hzqkznvRl2b2%2Bj8P4Qr8%2BGyB6ZoXlbhGwRfjA//RXuaIKJtSFOV6DD/BwuseX%2BKE8VYHcLZJuOZ3hr1zjbDqb5%2BAK0hGFm7xTd6yMM3hNj2HQxyO88zyMfpjkwDfEoFF6bZOPdGTZvbeOfE6McWgVju3Ls2J/ioyLEm6HwTp7udWGGt8YYsn3lWSq9OXr2p%2BbPCkHZWPgAeFr0GC1PAJ%2Bokls17ez5tWz2aRi9uCnOm70reKMzwgHR/6VsrPI3yHaD3h0FtgCvyGY7cMi64DfgXSnN6Bn1/IgrrE4Vk8lfug/ix/IcPFWkmCuzB/i/WhLZrtTwGmI%2B0gv6hjwqm6%2BA260I97g7/QRwq4omkBngGgfobytAa71ZOJcrz%2B1JCEBONsMKol0tbHIEeEyMomJ%2BuXoOmHIHMO50Z4FNYgod0uFG8bQuprTYCfZ0K/JAXgU%2Bc4Dm5FKTcEDtFki/qBvUekLRJsUGmg1Jl4JfgfuAM85PoYrZBQFUy0/69D7pGEi5uyCQtGPOANyifq8ptUZxIFbZz4pWXBGG3fVaUb6DFMyomA//l/PLYaCg/AUyrmj93mmNVl8777nOWRKAavlT94L/uLCauV7v6pLFABhXf09WgboZGFsOAEG%2BR53uDzEwuhwA0HQbdOszOrzuf1LCiwRg7fedi/icfj/W6%2BjfAAAA///cZAAN8LSlZAAAAABJRU5ErkJggg%3D%3D
[zenodo-badge]: https://zenodo.org/badge/DOI/10.5281/zenodo.4408776.svg
[zenodo-link]: https://doi.org/10.5281/zenodo.4408776
