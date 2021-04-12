#!/usr/bin/env bash
set -ev
INSTALL_DIR="${1:-/opt}"
# Essential
apt-get update -qq
apt-get install -yq curl
apt-get install -yq --no-install-recommends \
  bash-completion      \
  build-essential      \
  git                  \
  g++-7                \
  gcc-7                \
  man                  \
  make                 \
  ccache               \
  sudo
apt-get clean

pushd $INSTALL_DIR

# CMake
curl -o cmake.tgz -L https://github.com/Kitware/CMake/releases/download/v3.13.4/cmake-3.13.4-Linux-x86_64.tar.gz
tar xzf cmake.tgz && rm cmake.tgz
ln -s cmake-*x86_64 cmake
export PATH="$PWD/cmake/bin:$PATH"

# ccache
mkdir -p bin
pushd bin
# ccache compiler override
ln -s "$(which ccache)" g++
ln -s "$(which ccache)" g++-6
ln -s "$(which ccache)" g++-7
ln -s "$(which ccache)" gcc
ln -s "$(which ccache)" gcc-6
ln -s "$(which ccache)" gcc-7
export PATH="$PWD:$PATH"
popd

popd
