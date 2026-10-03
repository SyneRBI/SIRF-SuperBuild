# SIRF 3.10.1 (Windows) - C++ + Python, CPU only.
# Gadgetron / ISMRMRD / pet-rd-tools come from the sibling conda outputs
# (%LIBRARY_PREFIX%); STIR + NIFTYREG from conda-forge. Unix: build-sirf.sh.
$ErrorActionPreference = "Stop"

# PowerShell 5.1 does not treat native exit codes as errors, so check them explicitly.
function Assert-Zero($msg) { if ($LASTEXITCODE -ne 0) { throw "$msg failed with exit code $LASTEXITCODE" } }

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

# conda-forge's libzlib (win-64) ships only zlib.dll -- no import library -- so
# CMake's find_library(z) cannot link the niftyreg 'z' dependency. Generate the
# import lib from the DLL's exported symbols (dumpbin + lib /def).
$zlib_dll = Join-Path $env:PREFIX "Library\bin\zlib.dll"
if (Test-Path $zlib_dll) {
    $zlib_lib_dir = Join-Path $env:PREFIX "Library\lib"
    New-Item -ItemType Directory -Force -Path $zlib_lib_dir | Out-Null
    $zlib_lib = Join-Path $zlib_lib_dir "zlib.lib"
    if (-not (Test-Path $zlib_lib)) {
        $def = Join-Path $zlib_lib_dir "zlib.def"
        $exports = & dumpbin /exports /noheaders $zlib_dll
        Write-Host "zlib.dll exports (first 5):"; $exports | Select-Object -First 5 | ForEach-Object { Write-Host $_ }
        # dumpbin /exports lines: <ordinal> <hint> <rva> <name> (name is last).
        $names = @($exports | ForEach-Object {
            $c = $_.Trim() -split '\s+'
            if ($c.Count -ge 4 -and $c[0] -match '^[0-9a-f]+$') { $c[$c.Count - 1] }
        } | Where-Object { $_ -match '^[A-Za-z_]' })
        if ($names.Count -eq 0) { throw "dumpbin: no exports parsed from zlib.dll" }
        ("LIBRARY zlib", "EXPORTS") + ("  " + $names) | Set-Content -Path $def -Encoding ASCII
        & lib /def:$def /out:$zlib_lib /nologo
        Assert-Zero "lib (zlib import lib)"
    }
    Copy-Item -Force $zlib_lib (Join-Path $zlib_lib_dir "z.lib")
}
cmake -G Ninja $env:SRC_DIR -B "$env:BUILD_PREFIX\build" "-DCMAKE_BUILD_TYPE=Release" "-DCMAKE_INSTALL_PREFIX=$env:PREFIX" "-DCMAKE_PREFIX_PATH=$env:LIBRARY_PREFIX;$env:PREFIX" "-DRUN_ISMRMRD_SHEPP_LOGAN:BOOL=OFF" "-DDISABLE_Matlab:BOOL=ON" "-DDISABLE_PYTHON:BOOL=OFF" "-DPython_EXECUTABLE=$env:PREFIX\python.exe" "-DPYTHON_DEST_DIR=$env:SP_DIR" "-DDISABLE_Registration:BOOL=OFF" "-DDISABLE_Gadgetron:BOOL=OFF" "-DGadgetron_USE_CUDA:BOOL=OFF"
Assert-Zero "cmake configure"
cmake --build (Join-Path $env:BUILD_PREFIX "build") --config Release
Assert-Zero "cmake build"
cmake --install (Join-Path $env:BUILD_PREFIX "build") --config Release
Assert-Zero "cmake install"

# SIRF-Contribs (pure-Python, extends the sirf namespace with sirf.contrib)
& "$env:PREFIX\python.exe" -m pip install "git+https://github.com/SyneRBI/SIRF-Contribs.git@v3.10.0"

# SIRF runtime env vars on activation (Windows runs .bat, not .sh)
New-Item -ItemType Directory -Force "$env:PREFIX\etc\conda\activate.d" | Out-Null
Copy-Item "$env:RECIPE_DIR\activate-sirf.bat" "$env:PREFIX\etc\conda\activate.d\sirf-activate.bat"
