# SIRF 3.10.1 (Windows) - C++ + Python, CPU only.
# Gadgetron / ISMRMRD / pet-rd-tools come from the sibling conda outputs
# (%LIBRARY_PREFIX%); STIR + NIFTYREG from conda-forge. Unix: build-sirf.sh.
$ErrorActionPreference = "Stop"

# NiftyReg 1.5.69.6 (the only conda-forge build) ships a broken inline getter in
# _reg_aladin.h (see build-sirf.sh); SIRF never calls it, so neutralise it.
$h = Join-Path $env:LIBRARY_PREFIX "include\_reg_aladin.h"
$s = Get-Content $h -Raw
if ($s -match 'return this->InputTransform;') {
    # Replace (not in-place write): files are hardlinked out of the rattler
    # package cache; in-place edits would poison later builds' cache restores.
    $t = "$h~"
    Set-Content -Path $t -Value ($s -replace 'return this->InputTransform;', 'return nullptr;') -NoNewline
    Move-Item -Force $t $h
} elseif ($s -match 'GetInputTransform') {
    Write-Host "niftyreg: buggy getter absent (already patched or fixed upstream), skipping"
} else {
    throw "niftyreg _reg_aladin.h: not a _reg_aladin.h (no GetInputTransform)"
}

cmake -G Ninja $env:SRC_DIR -B "$env:BUILD_PREFIX\build" "-DCMAKE_BUILD_TYPE=Release" "-DCMAKE_INSTALL_PREFIX=$env:PREFIX" "-DCMAKE_PREFIX_PATH=$env:LIBRARY_PREFIX;$env:PREFIX" "-DRUN_ISMRMRD_SHEPP_LOGAN:BOOL=OFF" "-DDISABLE_Matlab:BOOL=ON" "-DDISABLE_PYTHON:BOOL=OFF" "-DPython_EXECUTABLE=$env:PREFIX\python.exe" "-DPYTHON_DEST_DIR=$env:SP_DIR" "-DDISABLE_Registration:BOOL=OFF" "-DDISABLE_Gadgetron:BOOL=OFF" "-DGadgetron_USE_CUDA:BOOL=OFF"
cmake --build (Join-Path $env:BUILD_PREFIX "build") --config Release
cmake --install (Join-Path $env:BUILD_PREFIX "build") --config Release

# SIRF-Contribs (pure-Python, extends the sirf namespace with sirf.contrib)
& "$env:PREFIX\python.exe" -m pip install "git+https://github.com/SyneRBI/SIRF-Contribs.git@v3.10.0"

# SIRF runtime env vars on activation (Windows runs .bat, not .sh)
New-Item -ItemType Directory -Force "$env:PREFIX\etc\conda\activate.d" | Out-Null
Copy-Item "$env:RECIPE_DIR\activate-sirf.bat" "$env:PREFIX\etc\conda\activate.d\sirf-activate.bat"
