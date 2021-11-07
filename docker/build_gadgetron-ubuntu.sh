#!/usr/bin/env bash
set -ev
# Gadgetron requirements
# from https://github.com/gadgetron/gadgetron/blob/master/docker/base/ubuntu_1804/Dockerfile#L8
apt-get update -qq
apt-get install -yq --no-install-recommends \
  libhdf5-serial-dev     \
  libboost-dev libboost-chrono-dev \
  libboost-filesystem-dev libboost-thread-dev \
  libboost-date-time-dev libboost-regex-dev \
  libboost-program-options-dev libboost-atomic-dev \
  libboost-test-dev libboost-timer-dev \
  libfftw3-dev           \
  h5utils                \
  jq                     \
  hdf5-tools             \
  libatlas-base-dev      \
  libxml2-dev            \
  libfreetype6-dev       \
  libxslt-dev            \
  libarmadillo-dev       \
  libace-dev             \
  liblapack-dev          \
  liblapacke-dev         \
  libplplot-dev          \
  libdcmtk-dev           \
  libpugixml-dev

# install GCC9 required by Gadgetron
apt-get install software-properties-common -y && \
add-apt-repository ppa:ubuntu-toolchain-r/test -y && \
apt-get update -y && \
apt-get install gcc-9 g++-9 -y

apt-get install -y librocksdb-dev

apt-get clean