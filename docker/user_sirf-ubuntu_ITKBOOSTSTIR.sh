#!/usr/bin/env bash
[ -f .bashrc ] && . .bashrc
set -ev
INSTALL_DIR="${1:-/opt}"

export PATH=$INSTALL_DIR/cmake/bin:$PATH

source "$INSTALL_DIR"/pyvenv/bin/activate

# SIRF
if [ ! -d $INSTALL_DIR/SIRF-SuperBuild ] 
then 
  git clone https://github.com/SyneRBI/SIRF-SuperBuild --recursive -b master $INSTALL_DIR/SIRF-SuperBuild
  pushd $INSTALL_DIR/SIRF-SuperBuild
  git checkout 9767f8adb189474e95f357ba1986e2755ba4a6dd
  popd
fi
pushd $INSTALL_DIR/SIRF-SuperBuild

COMPILER_FLAGS="-DCMAKE_C_COMPILER='$(which gcc)' -DCMAKE_CXX_COMPILER='$(which g++)'"
echo $PATH
echo $COMPILER_FLAGS
echo $BUILD_FLAGS $EXTRA_BUILD_FLAGS
cmake $BUILD_FLAGS $EXTRA_BUILD_FLAGS $COMPILER_FLAGS .

cmake --build . -j 12 --target Boost

cmake --build . -j 12 --target ITK

cmake --build . -j 12 --target STIR



popd
