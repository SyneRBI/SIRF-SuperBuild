#!/usr/bin/env bash
# Essential
apt-get update
apt-get install -y curl
apt-get install -y --no-install-recommends \
  bash-completion      \
  build-essential      \
  git                  \
  g++                  \
  man                  \
  make                 \
  sudo

# CMake
mkdir /opt/cmake
curl https://cmake.org/files/v3.7/cmake-3.7.2-Linux-x86_64.sh > cmake.sh
echo y | bash cmake.sh --prefix=/opt/cmake --exclude-subdir
export PATH="$PATH:/opt/cmake/bin"
rm cmake.sh
