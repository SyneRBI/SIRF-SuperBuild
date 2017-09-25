# SIRF-SuperBuild [![Build Status](https://travis-ci.org/CCPPETMR/SIRF-SuperBuild.svg?branch=master)](https://travis-ci.org/CCPPETMR/SIRF-SuperBuild)

The SIRF-SuperBuild allows the user to download and compile most of the software
needed to compile SIRF and Gadgetron, and automatically build SIRF and Gadgetron. 
There is still a small number of libraries that are not installed
by the SuperBuild ([more info for Linux](https://github.com/CCPPETMR/SIRF/wiki/SIRF-SuperBuild-Ubuntu-16.04#2-install-dependencies-for-gadgetron)).

## Dependencies

The superBuild depends on CMake >= 3.7.

## Generic instructions.

To compile and install SIRF with the SuperBuild:

 1. create a directory for the SuperBuild, e.g. devel.
 2. If you do not have CMake >= 3.7 install it first ([download link](https://cmake.org/download/)). On Linux,
you can issue the following commands

```bash
mkdir devel
cd devel
wget https://cmake.org/files/v3.7/cmake-3.7.2-Linux-x86_64.sh
sudo mkdir /opt/cmake
sudo bash cmake-3.7.2-Linux-x86_64.sh --prefix=/opt/cmake
export PATH=/opt/cmake/bin:$PATH
```
During installation you will be asked to read and accept CMake's license.

 3. Clone the project 

```bash
git clone https://github.com/CCPPETMR/SIRF-SuperBuild.git
cd SIRF-SuperBuild
```

 4. Build and install
```bash
cmake .
make
```
 
5. Source a script with the environment variables appropriate for your shell

For instance, for sh/bash/ksh etc
```bash
source INSTALL/bin/env_ccppetmr.sh
```
You probably want to add a similar line (with absolute path) to your .bashrc/.profile.

Or for csh
```csh
source INSTALL/bin/env_ccppetmr.csh
```
You probably want to add a similar line (with absolute path) to your .cshrc.

6. Testing

Tests for the SIRF-SuperBuild are currently the SIRF tests. The tests can contain tests from all SuperBuild projects.
After setting the environment variables, you can run tests as:
```bash
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

The user may also run the SIRF tests independently of the SuperBuild. Just enter the SIRF build directory and launch ctest:

```bash
cd SIRF-prefix/src/SIRF-build
ctest
```
## Build of specific versions
   
The SuperBuild allows the user to change the versions of the projects it's building. This is done at the configuration stage that happens when you issue the `cmake` command in the root of the Superbuild. 

There is a `DEVEL_BUILD` tag that allows to build the upstream/master versions of all packages
   
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

cmake . -DDEVEL_BUILD=ON
```

Additionally one may want to use only a specific version of a package. This is achieved by adding the right tag to the command line (see the table above for available tags):

```bash

cmake . -DSIRF_TAG=<a valid hash>
```

## Installation instructions for Ubuntu 16

They can be found [here](https://github.com/CCPPETMR/SIRF/wiki/SIRF-SuperBuild-Ubuntu-16.04)

## Installation instructions for Mac OS

They can be found [here](https://github.com/CCPPETMR/SIRF/wiki/SIRF-SuperBuild-on-MacOS)

## Installation instructions for Docker

They can be found [here](https://github.com/CCPPETMR/SIRF/wiki/SIRF-SuperBuild-on-Docker)

## TODO

- ***Windows support***
- Sort out CMake Status messages.
