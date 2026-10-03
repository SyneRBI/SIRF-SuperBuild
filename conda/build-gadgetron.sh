#!/usr/bin/env bash
# Gadgetron 4.7.2 (SyneRBI fork) — CPU by default, CUDA when USE_CUDA=ON.
set -euxo pipefail

if [ "${USE_CUDA:-OFF}" = "ON" ]; then
  export CUDA_TOOLKIT_ROOT_DIR="${PREFIX}"
  export CUDA_ROOT="${PREFIX}"
  # FindCUDA fix for conda cuda>=13.1
  export CUDA_INC_PATH="${PREFIX}/targets/x86_64-linux"
  export CUDA_LIB_PATH="${PREFIX}/targets/x86_64-linux"
  # CUDA 12.6+ splits the nvvm device compiler (cicc) into <toolkit>/nvvm/bin,
  # which nvcc locates via PATH; the toolkit (cuda-nvcc) lives in the build env.
  export PATH="${BUILD_PREFIX}/nvvm/bin:${PATH}"
fi

# Standalone GPU apps are host .cpp files whose thrust symbol mangling
# mismatches the GPU toolbox on CUDA 12.6; not needed by SIRF. The disable
# flag must be the final cmake arg: rattler-build mangles further
# backslash-continued lines, and comments would end the logical line.
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
  -DBUILD_SUPPRESS_WARNINGS:BOOL=ON -DDISABLE_STANDALONE_GPU_APPS:BOOL=${USE_CUDA:-OFF}

cmake --build $BUILD_PREFIX/build --config Release
cmake --install $BUILD_PREFIX/build --config Release
