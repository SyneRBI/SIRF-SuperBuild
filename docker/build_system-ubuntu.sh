#!/usr/bin/env bash
set -ev
# SIRF external dependencies
apt-get update -qq
apt-get install -yq --no-install-recommends \
  libboost-dev libboost-chrono-dev \
  libboost-filesystem-dev libboost-thread-dev \
  libboost-date-time-dev libboost-regex-dev \
  libboost-program-options-dev libboost-atomic-dev \
  libboost-test-dev libboost-timer-dev \
  libfftw3-dev         \
  libhdf5-serial-dev   \
  swig

# siemens_to_ismrmrd external dependencies
apt-get install -yq --no-install-recommends \
  libxml2-dev          \
  libxslt-dev

# ASTRA toolbox external dependencies
apt-get install -yq --no-install-recommends \
  autotools-dev        \
  automake             \
  autogen              \
  autoconf             \
  libtool

apt-get clean
