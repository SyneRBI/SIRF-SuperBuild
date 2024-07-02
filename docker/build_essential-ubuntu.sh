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
  cmake           \
  ninja-build     \
  ccache          \
  sudo            \
  unzip
apt-get clean

pushd $INSTALL_DIR
curl -o cmake.tgz -L https://github.com/Kitware/CMake/releases/download/v3.29.6/cmake-3.29.6-linux-x86_64.tar.gz
tar xzf cmake.tgz && rm cmake.tgz
ln -s cmake-*x86_64 cmake || true
ln -s $INSTALL_DIR/cmake/bin/cmake /usr/local/bin/cmake || true
export PATH="$PWD/cmake/bin:$PATH"

# CMake
#curl -o cmake.tgz -L https://github.com/Kitware/CMake/releases/download/v3.25.1/cmake-3.25.1-linux-x86_64.tar.gz
#tar xzf cmake.tgz && rm cmake.tgz
#ln -s cmake-*x86_64 cmake || true
#export PATH="$PWD/cmake/bin:$PATH"

# ccache
mkdir -p bin
pushd bin
# ccache compiler override
ln -s "$(which ccache)" g++ || true
ln -s "$(which ccache)" gcc || true
export PATH="$PWD:$PATH"
popd

popd
