#!/usr/bin/env bash
# Gadgetron 4.7.2 (SyneRBI fork) — CPU-only.
set -euxo pipefail

cmake -G Ninja $SRC_DIR \
  -B $BUILD_PREFIX/build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DUSE_CUDA:BOOL=OFF \
  -DUSE_OPENMP:BOOL=ON \
  -DBUILD_PYTHON_SUPPORT:BOOL=OFF \
  -DBUILD_MATLAB_SUPPORT:BOOL=OFF \
  -DBUILD_TESTING:BOOL=OFF \
  -DBUILD_SUPPRESS_WARNINGS:BOOL=ON

cmake --build $BUILD_PREFIX/build --config Release
cmake --install $BUILD_PREFIX/build --config Release
