#!/usr/bin/env bash
set -ev
# Gadgetron requirements
# from https://github.com/gadgetron/gadgetron/blob/master/docker/base/ubuntu_1804/Dockerfile#L8
apt-get update -qq
apt-get install -yq --no-install-recommends \
  libboost-dev libboost-chrono-dev \
        libboost-filesystem-dev libboost-thread-dev \
        libboost-date-time-dev libboost-regex-dev \
        libboost-program-options-dev libboost-atomic-dev \
        libboost-test-dev libboost-timer-dev \
  libfftw3-dev           \
  jq                     \
  libatlas-base-dev      \
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
