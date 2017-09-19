#!/usr/bin/env bash
# SIRF
git clone https://github.com/CCPPETMR/SIRF-SuperBuild
pushd SIRF-SuperBuild
cmake .
make -j

[ -f INSTALL/share/gadgetron/config/gadgetron.xml ] || \
  mv INSTALL/share/gadgetron/config/gadgetron.xml.example \
     INSTALL/share/gadgetron/config/gadgetron.xml
popd
