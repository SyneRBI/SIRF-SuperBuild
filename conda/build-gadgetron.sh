#!/usr/bin/env bash
# Gadgetron 4.7.2 (SyneRBI fork) — CPU by default, CUDA when USE_CUDA=ON.
set -euxo pipefail

if [ "${USE_CUDA:-OFF}" = "ON" ]; then
  export CUDA_TOOLKIT_ROOT_DIR="${PREFIX}"
  export CUDA_ROOT="${PREFIX}"
  # CUDA 12.6+ splits the nvvm device compiler (cicc) into <toolkit>/nvvm/bin,
  # which nvcc locates via PATH; the toolkit (cuda-nvcc) lives in the build env.
  export PATH="${BUILD_PREFIX}/nvvm/bin:${PATH}"
fi

cmake -G Ninja $SRC_DIR \
  -B $BUILD_PREFIX/build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DUSE_CUDA:BOOL=${USE_CUDA:-OFF} \
  -DUSE_OPENMP:BOOL=ON \
  -DBUILD_PYTHON_SUPPORT:BOOL=OFF \
  -DBUILD_MATLAB_SUPPORT:BOOL=OFF \
  -DBUILD_TESTING:BOOL=OFF \
  -DBUILD_SUPPRESS_WARNINGS:BOOL=ON

cmake --build $BUILD_PREFIX/build --config Release
cmake --install $BUILD_PREFIX/build --config Release
