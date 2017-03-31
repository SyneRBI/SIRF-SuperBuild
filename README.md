# SIRF-SuperBuild

The SIRF-SuperBuild will allow the user to download and compile all the software
needed to compile SIRF.

## Dependencies

The superBuild depends on CMake >= 3.7.

## Install

To compile and install SIRF with the SuperBuild:

 1. create a directory for the SuperBuild, e.g. devel.
 * issue the following commands

```bash
mkdir devel
cd devel
wget https://cmake.org/files/v3.7/cmake-3.7.2-Linux-x86_64.sh
sudo mkdir /opt/cmake
sudo bash cmake-3.7.2-Linux-x86_64.sh --prefix=/opt/cmake
export PATH=/opt/cmake/bin:$PATH
git clone https://github.com/CCPPETMR/SIRF-SuperBuild.git
cd SIRF-SuperBuild
cmake .
make
```
Please notice that if you do not have CMake >= 3.7 you need to install it. During installation you will be asked to read and accept CMake's license.

## TODO

- ***Windows support***
- Add swig
- Sort out CMake Status messages.
