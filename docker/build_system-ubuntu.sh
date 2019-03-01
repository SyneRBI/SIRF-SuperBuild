#!/usr/bin/env bash
set -ev
# SIRF external dependencies
apt-get update -qq
apt-get install -yq --no-install-recommends \
  hdfview              \
  libboost-all-dev     \
  libgtest-dev         \
  swig
apt-get clean

# Not required (yet) by SIRF
# libopenblas-dev
