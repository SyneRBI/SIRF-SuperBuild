#!/usr/bin/env bash
set -ev
# Gadgetron
apt-get update -qq
apt-get install -yq --no-install-recommends \
  h5utils              \
  liblapack-dev        \
  libace-dev
apt-get clean
