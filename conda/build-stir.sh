#!/usr/bin/env bash
# STIR 6.4.0 — options follow the SIRF-SuperBuild (SharedLibs, Executables,
# SWIG Python, OpenMP, HDF5, CERN ROOT; no CUDA, no LLN matrix).
set -euxo pipefail

cmake -G Ninja $SRC_DIR \
  -B $BUILD_PREFIX/build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DBUILD_SHARED_LIBS:BOOL=ON \
  -DBUILD_EXECUTABLES:BOOL=ON \
  -DBUILD_SWIG_PYTHON:BOOL=ON \
  -DPYTHON_DEST=$SP_DIR \
  -DPython_EXECUTABLE=$(which python) \
  -DSTIR_OPENMP:BOOL=ON \
  -DGRAPHICS=None \
  -DDISABLE_HDF5:BOOL=OFF \
  -DDISABLE_LLN_MATRIX:BOOL=ON \
  -DDISABLE_NLOHMANN_JSON:BOOL=OFF \
  -DDISABLE_ITK:BOOL=OFF \
  -DDISABLE_CERN_ROOT:BOOL=OFF \
  -DDISABLE_STIR_CUDA:BOOL=ON \
  -DDISABLE_PETSIRD:BOOL=ON \
  -DBUILD_TESTING:BOOL=OFF

cmake --build $BUILD_PREFIX/build --config Release
cmake --install $BUILD_PREFIX/build --config Release

# STIR executables need STIR_CONFIG_DIR at runtime
mkdir -p "$PREFIX/etc/conda/activate.d"
cp "$RECIPE_DIR/activate-stir.sh" "$PREFIX/etc/conda/activate.d/stir-activate.sh"
