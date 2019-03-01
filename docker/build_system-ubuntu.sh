#!/usr/bin/env bash
set -ev
# SIRF external dependencies
apt-get update -qq
apt-get install -yq --no-install-recommends \
  libboost-all-dev     \
  libfftw3-dev         \
  libhdf5-serial-dev   \
  swig
apt-get clean
