# SIRF-SuperBuild

The SIRF-SuperBuild will allow the user to download and compile all the software
needed to compile SIRF. There is still a [small number](https://github.com/CCPPETMR/SIRF/wiki/SIRF-SuperBuild-Ubuntu-16.04#2-install-dependencies-for-gadgetron) of libraries that are not installed.
by the SuperBuild.

## Dependencies

The superBuild depends on CMake >= 3.7.

## Install

The following instructions are specific to a Linux system.

To compile and install SIRF with the SuperBuild:

 1. create a directory for the SuperBuild, e.g. devel.
 2. If you do not have CMake >= 3.7 issue the following commands

```bash
mkdir devel
cd devel
wget https://cmake.org/files/v3.7/cmake-3.7.2-Linux-x86_64.sh
sudo mkdir /opt/cmake
sudo bash cmake-3.7.2-Linux-x86_64.sh --prefix=/opt/cmake
export PATH=/opt/cmake/bin:$PATH
```

 3. Clone the project 

```bash
git clone https://github.com/CCPPETMR/SIRF-SuperBuild.git
cd SIRF-SuperBuild
cmake .
make
```

Please notice that if you do not have CMake >= 3.7 you need to install it. During installation you will be asked to read and accept CMake's license.

## Installation instruction for Ubuntu 16.10

They can be found [here](https://github.com/CCPPETMR/SIRF/wiki/SIRF-SuperBuild-Ubuntu-16.04)

## TODO

- ***Windows support***
- Sort out CMake Status messages.


