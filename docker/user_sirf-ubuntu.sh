#!/usr/bin/env bash
# This script builds the SIRF-SuperBuild
# It relies on certain env variables to be set and should not be used
# outside of the "docker build" setting

[ -f .bashrc ] && . .bashrc
set -v
# set default installation location
INSTALL_DIR="${1:-/opt}"
# set default URL/tag
: ${SIRF_SB_URL:=https://github.com/SyneRBI/SIRF-SuperBuild}
: ${SIRF_SB_TAG:=master}
# set default number of parallel builds
: ${NUM_PARALLEL_BUILDS:=2}
# set default for cleaning up
: ${REMOVE_BUILD_FILES:=1}
# set default for running ctest during the build
: ${RUN_CTEST:=1}

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
# save installation location for below
CMAKE_INSTALL_PREFIX="${INSTALL_DIR}/SIRF-SuperBuild/INSTALL"

cmake --build . -j ${NUM_PARALLEL_BUILDS}

if [ "$RUN_CTEST" = 1 ]; then
    source "$CMAKE_INSTALL_PREFIX"/bin/env_sirf.sh
    # start gadgetron
    [ -f "$CMAKE_INSTALL_PREFIX"/bin/gadgetron ] && "$CMAKE_INSTALL_PREFIX"/bin/gadgetron >& gadgetron.log&
    ctest --output-on-failure
    [ -n "$(pidof gadgetron)" ] && kill -n 15 $(pidof gadgetron)
fi

if [ "$REMOVE_BUILD_FILES" = 1 ]; then
    echo  "Removing most build files"
    rm -rf builds gadgetron.log
    for s in sources/*/.git; do
        cd $s/..
        git clean -fdx
        cd ../..
    done
else
    echo  "Keeping build files"
fi

