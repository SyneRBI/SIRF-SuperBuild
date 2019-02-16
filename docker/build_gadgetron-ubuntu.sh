#!/usr/bin/env bash
set -ev
# Gadgetron
apt-get update -qq
apt-get install -yq --no-install-recommends \
  h5utils              \
  liblapack-dev        \
  libace-dev
# Not required (yet) by SIRF
# libxml2-dev
# libxslt-dev
# python-h5py
# python-libxml2
# python-psutil
# libplplot-dev
apt-get clean
