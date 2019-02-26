#!/usr/bin/env bash
set -ev
# SIRF external dependencies
apt-get update -qq
apt-get install -yq --no-install-recommends \
  hdf5-tools           \
  hdfview              \
  libarmadillo-dev     \
  libboost-all-dev     \
  libfftw3-dev         \
  libgtest-dev         \
  libhdf5-serial-dev   \
  libplplot-dev        \
  libxml2-dev          \
  libxslt-dev          \
  swig
apt-get clean

# Not required (yet) by SIRF
# libxml2-dev
# libxslt-dev
# python-h5py
# python-libxml2
# python-psutil
# libplplot-dev
# libopenblas-dev
# libatlas-base-dev
