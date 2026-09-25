#!/usr/bin/env bash
# SIRF 3.10.1 — C++ + Python (CPU). STIR / Gadgetron / NIFTYREG / ISMRMRD
# come from the sibling conda outputs and the ismrmrd channel.
set -euxo pipefail

# NiftyReg 1.5.69.6 (the only conda-forge build) ships a broken inline getter in
# _reg_aladin.h: reg_aladin<T>::GetInputTransform() returns this->InputTransform,
# but no such member exists (only `char *InputTransformName`). Being an inline
# template method, it only fails when SIRF instantiates reg_aladin (in
# NiftyAladinSym.cpp). SIRF never calls GetInputTransform(), so neutralise it.
# (The SuperBuild instead builds NiftyReg from commit a328efb, which lacks this bug.)
sed -i 's/return this->InputTransform;/return nullptr;/' "$PREFIX/include/_reg_aladin.h"

cmake -G Ninja $SRC_DIR \
  -B $BUILD_PREFIX/build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DDISABLE_Matlab:BOOL=ON \
  -DDISABLE_PYTHON:BOOL=OFF \
  -DPython_EXECUTABLE=$(which python) \
  -DPYTHON_DEST_DIR=$SP_DIR \
  -DDISABLE_Registration:BOOL=OFF \
  -DDISABLE_Gadgetron:BOOL=OFF

cmake --build $BUILD_PREFIX/build --config Release
cmake --install $BUILD_PREFIX/build --config Release

# SIRF-Contribs (pure-Python, extends the sirf namespace with sirf.contrib)
$PREFIX/bin/python -m pip install "git+https://github.com/SyneRBI/SIRF-Contribs.git@v3.10.0"

# SIRF runtime env vars on activation (examples_data_path, Gadgetron relay)
mkdir -p "$PREFIX/etc/conda/activate.d"
cp "$RECIPE_DIR/activate-sirf.sh" "$PREFIX/etc/conda/activate.d/sirf-activate.sh"
