#!/usr/bin/env bash
set -ev
apt-get update -qq
apt-get install -yq --no-install-recommends \
  python-dev           \
  python-tk
apt-get clean
