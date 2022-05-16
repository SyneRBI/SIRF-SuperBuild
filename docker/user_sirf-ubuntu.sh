#!/usr/bin/env bash
[ -f .bashrc ] && . .bashrc
set -ev
INSTALL_DIR="${1:-/opt}"
# set default URL/tag
: ${SIRF_SB_URL:=https://github.com/SyneRBI/SIRF-SuperBuild}
: ${SIRF_SB_TAG:=master}
# set default number of parallel builds
: ${NUM_PARALLEL_BUILDS:=2}

git clone "$SIRF_SB_URL" --recursive "$INSTALL_DIR"/SIRF-SuperBuild
cd $INSTALL_DIR/SIRF-SuperBuild
git checkout "$SIRF_SB_TAG"

COMPILER_FLAGS="-DCMAKE_C_COMPILER='$(which gcc)' -DCMAKE_CXX_COMPILER='$(which g++)'"
echo $PATH
echo $COMPILER_FLAGS
echo $BUILD_FLAGS $EXTRA_BUILD_FLAGS
cmake $BUILD_FLAGS $EXTRA_BUILD_FLAGS $COMPILER_FLAGS .

cmake --build . -j ${NUM_PARALLEL_BUILDS} --target Gadgetron

#cmake --build . -j ${NUM_PARALLEL_BUILDS}
