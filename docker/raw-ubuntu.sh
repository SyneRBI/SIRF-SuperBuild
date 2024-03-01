#!/usr/bin/env bash
set -ev
# minor Ubuntu base image updates

# Set locale, suppress warnings
apt-get update
apt-get install -yq apt-utils locales
locale-gen en_GB.UTF-8
#export LC_ALL=en_GB.UTF-8
export LANG=en_GB.UTF-8
export LANGUAGE=en_GB:en
#localectl set-locale LANG="en_GB.UTF-8"

# SSL fix
apt-get install -yq ca-certificates

apt-get clean
