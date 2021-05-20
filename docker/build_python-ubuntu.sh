#!/usr/bin/env bash
set -ev
apt-get update -qq
apt-get install -yq --no-install-recommends \
  python3-dev           \
  python3-tk
apt-get clean
