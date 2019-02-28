#!/usr/bin/env bash
[ -f .bashrc ] && . .bashrc
set -ev
# SIRF
git clone https://github.com/CCPPETMR/SIRF-SuperBuild --recursive -b docker /opt/SIRF-SuperBuild
pushd /opt/SIRF-SuperBuild
echo $BUILD_FLAGS $EXTRA_BUILD_FLAGS
cmake $BUILD_FLAGS $EXTRA_BUILD_FLAGS .
make -j 2

[ -f INSTALL/share/gadgetron/config/gadgetron.xml ] || \
  mv INSTALL/share/gadgetron/config/gadgetron.xml.example \
     INSTALL/share/gadgetron/config/gadgetron.xml
popd
