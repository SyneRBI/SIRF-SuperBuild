#!/usr/bin/env bash
# pet-rd-tools 2.0.2 (nm_validate, nm_extract, nm_mrac2mu, nm_signa2mu).
set -euxo pipefail

cmake -G Ninja $SRC_DIR \
  -B $BUILD_PREFIX/build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DBUILD_TESTING:BOOL=OFF

cmake --build $BUILD_PREFIX/build --config Release
cmake --install $BUILD_PREFIX/build --config Release
