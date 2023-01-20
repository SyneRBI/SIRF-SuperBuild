#!/usr/bin/env bash
set -ev
apt-get update -qq
apt-get install -yq --no-install-recommends \
  python3-dev           \
  python3-tk            \
  python-is-python3
apt-get clean
