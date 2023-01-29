#!/usr/bin/env bash
# This script builds the SIRF-SuperBuild
# It relies on certain env variables to be set and should not be used
# outside of the "docker build" setting

[ -f .bashrc ] && . .bashrc
set -ev
# set default installation location
INSTALL_DIR="${1:-/opt}"
# set default URL/tag
: ${SIRF_SB_URL:=https://github.com/SyneRBI/SIRF-SuperBuild}
: ${SIRF_SB_TAG:=master}
# set default number of parallel builds
: ${NUM_PARALLEL_BUILDS:=2}
# set default for cleaning up
: ${REMOVE_BUILD_FILES:=0}

git clone "$SIRF_SB_URL" --recursive "$INSTALL_DIR"/SIRF-SuperBuild
cd $INSTALL_DIR/SIRF-SuperBuild
git checkout "$SIRF_SB_TAG"

COMPILER_FLAGS="-DCMAKE_C_COMPILER='$(which gcc)' -DCMAKE_CXX_COMPILER='$(which g++)'"
g++ --version
cmake --version
echo "PATH: $PATH"
echo "COMPILER_FLAGS: $COMPILER_FLAGS"
echo "BUILD+EXTRA FLAGS: $BUILD_FLAGS $EXTRA_BUILD_FLAGS"

cmake $BUILD_FLAGS $EXTRA_BUILD_FLAGS $COMPILER_FLAGS .

cmake --build . -j ${NUM_PARALLEL_BUILDS}

if [  "$REMOVE_BUILD_FILES" = 1 ]; then
    echo  "Removing most build files"
    rm -rf builds
    for s in sources/*/.git; do
        cd $s/..
        pwd
        git clean -fdx
        cd ../..
    done
else
    echo  "Keeping build files"
fi

