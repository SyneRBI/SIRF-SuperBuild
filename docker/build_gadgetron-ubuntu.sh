#!/usr/bin/env bash
set -ev
# Gadgetron requirements
# from https://github.com/gadgetron/gadgetron/blob/master/docker/base/ubuntu_1804/Dockerfile#L8
apt-get update -qq
# boost is handled in build_system-ubuntu.sh
apt-get install -yq --no-install-recommends \
  libboost-dev libboost-all-dev \
  libfftw3-dev           \
  jq                     \
  libopenblas-dev      \
  libxml2-dev            \
  libfreetype6-dev       \
  libxslt-dev            \
  liblapack-dev          \
  liblapacke-dev         \
  libplplot-dev          \
  libdcmtk-dev           \
  libpugixml-dev         \
  libgflags-dev          \
  libssl-dev             \
  libcurl4-openssl-dev   \
  pkg-config             

if [ ${USE_UBUNTU_SYSTEM_LIBRARIES} ] ; then
  echo "Installing Armadillo and go from system apt"
  apt-get install -yq --no-install-recommends \
    libarmadillo-dev       \
    libhdf5-serial-dev     \
    h5utils                \
    hdf5-tools             \
    golang
fi

# old code to install GCC9 as minimum required by Gadgetron, but now disabled as default in 22.04 is now gcc-11
# apt-get install software-properties-common -y && \
# add-apt-repository ppa:ubuntu-toolchain-r/test -y && \
# apt-get update -y && \
# apt-get install gcc-9 g++-9 -y

# apt-get install -y librocksdb-dev

apt-get clean

# install libgmock-dev if in the apt packages https://github.com/SyneRBI/SIRF-SuperBuild/issues/647#issuecomment-1042841986
if apt-cache show libgmock-dev >& /dev/null; then
  apt install -yq libgmock-dev libgtest-dev
else
  apt install -yq libgtest-dev
fi

