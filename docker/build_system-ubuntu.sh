#!/usr/bin/env bash
set -ev
# SIRF external dependencies
apt-get update -qq
apt-get install -yq --no-install-recommends \
  libboost-all-dev     \
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
