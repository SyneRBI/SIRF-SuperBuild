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
  g++                \
  gcc                \
  man                  \
  make                 \
  ccache               \
  sudo                 \
  unzip
apt-get clean

pushd $INSTALL_DIR

# CMake
curl -o cmake.tgz -L https://github.com/Kitware/CMake/releases/download/v3.24.1/cmake-3.24.1-Linux-x86_64.tar.gz
tar xzf cmake.tgz && rm cmake.tgz
ln -s cmake-*x86_64 cmake || true
export PATH="$PWD/cmake/bin:$PATH"

# ccache
mkdir -p bin
pushd bin
# ccache compiler override
ln -s "$(which ccache)" g++ || true
ln -s "$(which ccache)" gcc || true
export PATH="$PWD:$PATH"
popd

popd
