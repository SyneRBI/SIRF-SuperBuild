#!/usr/bin/env bash
set -ev
INSTALL_DIR="${1:-/opt}"
# Essential
apt-get update -qq
apt-get install -yq curl
apt-get install -yq --no-install-recommends \
  bash-completion \
  build-essential \
  git             \
  g++             \
  gcc             \
  man             \
  ninja-build     \
  ccache          \
  sudo            \
  unzip
apt-get clean

pushd $INSTALL_DIR

# CMake
curl -o cmake.tgz -L https://github.com/Kitware/CMake/releases/download/v3.29.6/cmake-3.29.6-linux-x86_64.tar.gz
mkdir -p /usr/local
pushd /usr/local
tar xzf $INSTALL_DIR/cmake.tgz --strip 1
popd
rm cmake.tgz

# ccache
mkdir -p bin
pushd bin
# ccache compiler override
ln -s "$(which ccache)" g++ || true
ln -s "$(which ccache)" gcc || true
export PATH="$PWD:$PATH"
popd

popd
