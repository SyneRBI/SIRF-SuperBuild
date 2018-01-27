# SIRF-SuperBuild [![Build Status](https://travis-ci.org/CCPPETMR/SIRF-SuperBuild.svg?branch=master)](https://travis-ci.org/CCPPETMR/SIRF-SuperBuild)

The SIRF-SuperBuild allows the user to download and compile most of the software
needed to compile SIRF and Gadgetron, and automatically build SIRF and Gadgetron. 
There is still a small number of libraries that are not installed
by the SuperBuild, [see below for more info for your operating system](#os-specific-information).

## Dependencies

The superBuild depends on CMake >= 3.7.

## Generic instructions.

To compile and install SIRF with the SuperBuild follow these steps:

### Create a directory for the SuperBuild

```bash
cd ~
mkdir devel
```

### Install CMake >= 3.7 

If you do not have CMake >= 3.7 install it first ([download link](https://cmake.org/download/)). On Ubuntu Linux,
you can issue the following commands

```bash
cd ~
cd devel
wget https://cmake.org/files/v3.7/cmake-3.7.2-Linux-x86_64.sh
sudo mkdir /opt/cmake
sudo bash cmake-3.7.2-Linux-x86_64.sh --prefix=/opt/cmake
export PATH=/opt/cmake/bin:$PATH
```
During installation you will be asked to read and accept CMake's license. If you answered the last question during the CMake installation with yes, then you should use

```
export PATH=/opt/cmake/cmake-3.7.2-Linux-x86_64/bin:$PATH
```
Note that the above `PATH` statements won't work if you are running csh. The equivalent would be for instance
```csh
set path = ( /opt/cmake/bin $path )
```
You might want to add the `PATH` line to your start-up file (e.g. `.profile` or `.cshrc`).

### Clone the SIRF-SuperBuild project 

```bash
cd ~
cd devel
git clone https://github.com/CCPPETMR/SIRF-SuperBuild.git
```

 ### Build and install
 
 Create a build directory and configure the software.
 
```bash
cd ~/devel
mkdir build
cd build
cmake ../SIRF-SuperBuild
```
Use your build environment to build and install the project. On Linux/OSX etc, you would normally use
```bash
make -jN
```
where `N` are the number of cores you want to use for the compilation. For Eclipse/XCode/Visual Studio, you could open the project, or try something like
```bash
cmake --build . --config Release
```

Note that there is no separate install step.

### Rename the example configuration file for Gadgetron
```
mv INSTALL/share/gadgetron/config/gadgetron.xml.example INSTALL/share/gadgetron/config/gadgetron.xml
```

### Set Environment variables

Source a script with the environment variables appropriate for your shell

For instance, for sh/bash/ksh etc
```bash
cd ~/devel/build
source INSTALL/bin/env_ccppetmr.sh
```
You probably want to add a similar line (with absolute path) to your .bashrc/.profile.

Or for csh
```csh
source INSTALL/bin/env_ccppetmr.csh
```
You probably want to add a similar line (with absolute path) to your .cshrc.

### Open a terminal and start Gadgetron
If you didn't add any of the above statements to your .bashrc or .cshrc, you will have to source env_ccpetmr.* again in this terminal first.
```
gadgetron
```

### Testing

Tests for the SIRF-SuperBuild are currently the SIRF tests. The tests can contain tests from all SuperBuild projects.
After setting the environment variables and starting Gadgetron, you can run tests as:

```bash
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

```bash
cd ~/devel/build
cd SIRF-prefix/src/SIRF-build
ctest --verbose
```
If you see failures, you might not have followed the above steps correctly, or have some missing Python modules.

## Build of specific versions

By default, the SuperBuild will build the latest stable release of SIRF and associated versions of the dependencies. However, the SuperBuild allows the user to change the versions of the projects it's building. 

This is done at the configuration stage that happens when you run `cmake`. 

There is a `DEVEL_BUILD` tag that allows to build the upstream/master versions of all packages (`DEVEL_BUILD=ON`). In the following table are listed the default versions (hashes) of dependencies that are built by the SuperBuild (`DEVEL_BUILD=OFF`). 
   
|TAG        | DEVEL_BUILD=OFF (default) | DEVEL_BUILD=ON |
|:--------- |:--------------- |:-------------- |
|`SIRF_TAG` | `v0.9.0`          | `master`         |
|`STIR_URL` | https://github.com/CCPPETMR/STIR | https://github.com/UCL/STIR |
|`STIR_TAG` | `8bf37d9d7fdde7cb3a98a6f848d93827dbd98a18` | `master` |
|`Gadgetron_URL` | https://github.com/CCPPETMR/gadgetron |https://github.com/gadgetron/gadgetron |
|`Gadgetron_TAG` | `f03829ef45e57466829e6ec46da7a7cf61db1c8a`  | `master` |
|`ISMRMRD_URL` | https://github.com/CCPPETMR/ismrmrd | https://github.com/ismrmrd/ismrmrd |
|`ISMRMRD_TAG` | `35012c6c8000616546c2d6b1757eba0c5b21b2d4` | `master` |

To use the `DEVEL_BUILD` option one may (on the terminal)

```bash
cd ~/devel/build
cmake ../SIRF-SuperBuild -DDEVEL_BUILD=ON
```

Additionally one may want to use only a specific version of a package. This is achieved by adding the right tag to the command line (see the table above for available tags):

```bash
cd ~/devel/build
cmake ../SIRF-SuperBuild -DSIRF_TAG=<a valid hash>
```
Note that the CMake options in the table are Advanced Options. When running the CMake GUI (or ccmake) they will therefore only be visible when you toggle those on. Additionally, these variables are cached, so they will keep the specified value unless cache is deleted.

## OS specific information
### Installation instructions for Ubuntu

They can be found [here](https://github.com/CCPPETMR/SIRF/wiki/SIRF-SuperBuild-Ubuntu-16.04)

### Installation instructions for Mac OS

They can be found [here](https://github.com/CCPPETMR/SIRF/wiki/SIRF-SuperBuild-on-MacOS)

### Installation instructions for Docker

They can be found [here](https://github.com/CCPPETMR/SIRF/wiki/SIRF-SuperBuild-on-Docker)

## TODO

- ***Windows support***
- Sort out CMake Status messages.
