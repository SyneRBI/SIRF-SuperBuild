# SIRF 3.10.1 (Windows) - C++ + Python, CPU only.
# Gadgetron / ISMRMRD / pet-rd-tools come from the sibling conda outputs
# (%LIBRARY_PREFIX%); STIR + NIFTYREG from conda-forge. Unix: build-sirf.sh.
$PSNativeCommandUseErrorActionPreference = "True"
$ErrorActionPreference = "Stop"

# NiftyReg 1.5.69.6 (the only conda-forge build) ships a broken inline getter in
# _reg_aladin.h (see build-sirf.sh); SIRF never calls it, so neutralise it.
$h = Join-Path $PREFIX "include\_reg_aladin.h"
$s = Get-Content $h -Raw
if ($s -notmatch 'return this->InputTransform;') { throw "niftyreg _reg_aladin.h: expected pattern not found" }
Set-Content -Path $h -Value ($s -replace 'return this->InputTransform;', 'return nullptr;') -NoNewline

cmake -G Ninja $SRC_DIR -B (Join-Path $BUILD_PREFIX "build") -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_PREFIX_PATH="$LIBRARY_PREFIX;$PREFIX" -DRUN_ISMRMRD_SHEPP_LOGAN:BOOL=OFF -DDISABLE_Matlab:BOOL=ON -DDISABLE_PYTHON:BOOL=OFF -DPython_EXECUTABLE="$PREFIX\python.exe" -DPYTHON_DEST_DIR=$SP_DIR -DDISABLE_Registration:BOOL=OFF -DDISABLE_Gadgetron:BOOL=OFF -DGadgetron_USE_CUDA:BOOL=OFF
cmake --build (Join-Path $BUILD_PREFIX "build") --config Release
cmake --install (Join-Path $BUILD_PREFIX "build") --config Release

# SIRF-Contribs (pure-Python, extends the sirf namespace with sirf.contrib)
& "$PREFIX\python.exe" -m pip install "git+https://github.com/SyneRBI/SIRF-Contribs.git@v3.10.0"

# SIRF runtime env vars on activation (Windows runs .bat, not .sh)
New-Item -ItemType Directory -Force "$PREFIX\etc\conda\activate.d" | Out-Null
Copy-Item "$RECIPE_DIR\activate-sirf.bat" "$PREFIX\etc\conda\activate.d\sirf-activate.bat"
