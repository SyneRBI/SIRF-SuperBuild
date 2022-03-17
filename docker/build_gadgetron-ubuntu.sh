#!/usr/bin/env bash
set -ev
# Gadgetron requirements
# from https://github.com/gadgetron/gadgetron/blob/master/docker/base/ubuntu_1804/Dockerfile#L8
apt-get update -qq
# boost is handled in build_system-ubuntu.sh
apt-get install -yq --no-install-recommends \
  libhdf5-serial-dev     \
  libfftw3-dev           \
  h5utils                \
  jq                     \
  hdf5-tools             \
  libopenblas-dev      \
  libxml2-dev            \
  libfreetype6-dev       \
  libxslt-dev            \
  libarmadillo-dev       \
  libace-dev             \
  liblapack-dev          \
  liblapacke-dev         \
  libplplot-dev          \
  libdcmtk-dev
apt-get clean

# install libgmock-dev if in the apt packages https://github.com/SyneRBI/SIRF-SuperBuild/issues/647#issuecomment-1042841986
if apt-cache show libgmock-dev >& /dev/null; then
  apt install  libgmock-dev libgtest-dev
else
  apt install  libgtest-dev
fi

