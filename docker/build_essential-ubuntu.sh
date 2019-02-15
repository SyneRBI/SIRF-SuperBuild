#!/usr/bin/env bash
set -ev
# Essential
apt-get update -qq
apt-get install -yq curl
apt-get install -yq --no-install-recommends \
  bash-completion      \
  build-essential      \
  git                  \
  g++                  \
  man                  \
  make                 \
  ccache               \
  sudo
apt-get clean

# CMake
mkdir /opt/cmake
curl https://cmake.org/files/v3.7/cmake-3.7.2-Linux-x86_64.sh > cmake.sh
echo y | bash cmake.sh --prefix=/opt/cmake --exclude-subdir
export PATH="/opt/cmake/bin:$PATH"
rm cmake.sh
