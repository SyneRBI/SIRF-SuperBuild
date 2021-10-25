#!/bin/bash
# download/install recent cmake
# optional first argument is location (e.g. /usr/local (default), $HOME)
# If using a system location, execute with sudo
# You need to make sure the resulting location will be in your path

# Authors: Ben Thomas, Kris Thielemans
# Copyright 2017-2018 University College London

set -e
if [ $# -eq 0 ]
then
    INSTALL_LOC=/usr/local
else
    INSTALL_LOC=$1
fi
ver=3.21.3

echo "Downloading CMake $ver in /tmp"
cd /tmp
# next location could be for older releases (although 3.7.2 was in a 3.7 dir, not 3.7.2)
# wget -c https://cmake.org/files/${ver}/cmake-${ver}-Linux-x86_64.tar.gz
wget -c https://github.com/Kitware/CMake/releases/download/v${ver}/cmake-${ver}-Linux-x86_64.tar.gz

echo "Installing CMake $ver in ${INSTALL_LOC}"
cd ${INSTALL_LOC}
tar xzf /tmp/cmake-${ver}-Linux-x86_64.tar.gz --strip 1
rm /tmp/cmake-${ver}-Linux-x86_64.tar.gz
