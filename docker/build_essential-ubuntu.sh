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
  g++-8                \
  gcc-8                \
  man                  \
  make                 \
  ccache               \
  sudo                 \
  unzip
apt-get clean

pushd $INSTALL_DIR

# CMake
curl -o cmake.tgz -L https://github.com/Kitware/CMake/releases/download/v3.17.5/cmake-3.17.5-Linux-x86_64.tar.gz
tar xzf cmake.tgz && rm cmake.tgz
ln -s cmake-*x86_64 cmake
export PATH="$PWD/cmake/bin:$PATH"

# ccache
mkdir -p bin
pushd bin
# ccache compiler override
ln -s "$(which ccache)" g++
ln -s "$(which ccache)" g++-8
ln -s "$(which ccache)" gcc
ln -s "$(which ccache)" gcc-8
export PATH="$PWD:$PATH"
popd

popd
