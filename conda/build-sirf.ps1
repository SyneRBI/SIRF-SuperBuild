# SIRF 3.10.1 (Windows) - C++ + Python, CPU only.
# Gadgetron / ISMRMRD / pet-rd-tools come from the sibling conda outputs
# (%LIBRARY_PREFIX%); STIR + NIFTYREG from conda-forge. Unix: build-sirf.sh.
$ErrorActionPreference = "Stop"

# PowerShell 5.1 does not treat native exit codes as errors, so check them explicitly.
function Assert-Zero($msg) { if ($LASTEXITCODE -ne 0) { throw "$msg failed with exit code $LASTEXITCODE" } }

# NiftyReg 1.5.69.6 (the only conda-forge build) ships a broken inline getter in
# _reg_aladin.h (see build-sirf.sh); SIRF never calls it, so neutralise it.
$h = "$env:LIBRARY_PREFIX\include\_reg_aladin.h"
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
# import lib from the DLL's actual export set (dumpbin /exports + lib /def); a
# fixed list is too fragile (it misses e.g. the gz* stream API that
# niftyreg/reg_nifti links against).
$zlib_dll = "$env:PREFIX\Library\bin\zlib.dll"
if (Test-Path $zlib_dll) {
    $zlib_lib_dir = "$env:PREFIX\Library\lib"
    New-Item -ItemType Directory -Force -Path $zlib_lib_dir | Out-Null
    $zlib_lib = "$zlib_lib_dir\zlib.lib"
    if (-not (Test-Path $zlib_lib)) {
        # Export table rows: <VA> <RVA> <ordinal:8hex> <hint:8hex> <name>.
        # Key off the second-to-last field (hint/ordinal, 4+ hex) and the last
        # field (the C symbol name); the header row's last field is "Name" whose
        # second-to-last ("Hint") is not hex, so it is excluded.
        $names = & dumpbin /exports $zlib_dll 2>$null | ForEach-Object {
            $t = ($_.Trim()) -split '\s+'
            if ($t.Count -ge 4 -and $t[-2] -match '^[0-9a-fA-F]{4,}$' -and $t[-1] -match '^[A-Za-z_][A-Za-z0-9_]*$') { $t[-1] }
        } | Where-Object { $_ -ne 'Name' } | Sort-Object -Unique
        if (-not $names) { throw "dumpbin /exports returned no export names for $zlib_dll" }
        $def = "$zlib_lib_dir\zlib.def"
        $def_lines = @("LIBRARY zlib", "EXPORTS") + ($names | ForEach-Object { "  " + $_ })
        $enc = New-Object System.Text.ASCIIEncoding
        [System.IO.File]::WriteAllLines($def, $def_lines, $enc)
        Write-Host "zlib.def: $($names.Count) exports (from dumpbin /exports)"
        & lib /def:$def /out:$zlib_lib /nologo
        Assert-Zero "lib (zlib import lib)"
    }
    Copy-Item -Force $zlib_lib "$zlib_lib_dir\z.lib"
}
# range-v3 0.12's compressed_pair.hpp guards compressed_tuple_'s converting
# constructor / tuple operator with a SFINAE default template argument that
# multi-pack-expands META_IS_CONSTRUCTIBLE(Ts, Args).... MSVC 1944 (VS 2026)
# rejects that expansion with C3546 ("no parameter packs available to expand"),
# while the identical multi-pack expansions in the member initialiser list and
# the noexcept clause compile fine. range-v3 always constructs compressed_tuple_
# with matching element/argument types, so drop the SFINAE guards; constructi-
# bility is still enforced by the member initialisers.
$cp = "$env:LIBRARY_PREFIX\include\range\v3\utility\compressed_pair.hpp"
if (Test-Path $cp) {
    $s = [System.IO.File]::ReadAllText($cp)
    if ($s -match 'META_IS_CONSTRUCTIBLE\(Ts, Args\)\.\.\.') {
        $s = $s -replace 'template<typename\.\.\.\s*Args,[\r\n]+\s*meta::if_<meta::and_c<META_IS_CONSTRUCTIBLE\(Ts, Args\)\.\.\.>, int> = 0>', 'template<typename... Args>'
        $s = $s -replace 'template<[\r\n]+\s*typename\.\.\.\s*Us,[\r\n]+\s*meta::if_<meta::and_c<META_IS_CONSTRUCTIBLE\(Us, Ts const &\)\.\.\.>, int> = 0>', 'template<typename... Us>'
        $t = "$cp~"
        [System.IO.File]::WriteAllText($t, $s)
        Move-Item -Force $t $cp
        Write-Host "range-v3 compressed_pair.hpp: dropped MSVC-1944-breaking SFINAE guards"
    } else {
        Write-Host "range-v3 compressed_pair.hpp: SFINAE pattern absent (already patched / fixed upstream), skipping"
    }
} else {
    Write-Warning "range-v3 compressed_pair.hpp not found at $cp"
}
# Armadillo's arma_cmath.hpp calls std::isnan, but MSVC's <math.h> may define
# `isnan` as a macro to _isnan, turning `std::isnan` into the non-existent
# std::_isnan (C2039). The SYN C++ test TU pulls in <math.h> before Armadillo
# (the SIRF lib TUs do not, hence only the test fails). Undefine the macro at
# the top of the header so the C++11 std::isnan function is used.
$arma = "$env:LIBRARY_PREFIX\include\armadillo_bits\arma_cmath.hpp"
if (Test-Path $arma) {
    $s = [System.IO.File]::ReadAllText($arma)
    if ($s -match 'std::isnan' -and $s -notmatch '#undef isnan') {
        $t = "$arma~"
        [System.IO.File]::WriteAllText($t, "`n#ifdef isnan`n#undef isnan`n#endif`n`n" + $s)
        Move-Item -Force $t $arma
        Write-Host "armadillo arma_cmath.hpp: #undef'd isnan macro (MSVC std::_isnan)"
    }
}
cmake -G Ninja $env:SRC_DIR -B "$env:BUILD_PREFIX\build" "-DCMAKE_BUILD_TYPE=Release" "-DCMAKE_INSTALL_PREFIX=$env:PREFIX" "-DCMAKE_PREFIX_PATH=$env:LIBRARY_PREFIX;$env:PREFIX" "-DRUN_ISMRMRD_SHEPP_LOGAN:BOOL=OFF" "-DDOWNLOAD_ZENODO_TEST_DATA:BOOL=OFF" "-DDISABLE_Matlab:BOOL=ON" "-DDISABLE_PYTHON:BOOL=OFF" "-DPython_EXECUTABLE=$env:PREFIX\python.exe" "-DPYTHON_DEST_DIR=$env:SP_DIR" "-DDISABLE_Registration:BOOL=OFF" "-DDISABLE_Gadgetron:BOOL=OFF" "-DGadgetron_USE_CUDA:BOOL=OFF"
Assert-Zero "cmake configure"
cmake --build "$env:BUILD_PREFIX\build" --config Release
Assert-Zero "cmake build"
cmake --install "$env:BUILD_PREFIX\build" --config Release
Assert-Zero "cmake install"

# SIRF-Contribs (pure-Python, extends the sirf namespace with sirf.contrib)
& "$env:PREFIX\python.exe" -m pip install "git+https://github.com/SyneRBI/SIRF-Contribs.git@v3.10.0"

# SIRF runtime env vars on activation (examples_data_path, Gadgetron relay)
New-Item -ItemType Directory -Force "$env:PREFIX\etc\conda\activate.d" | Out-Null
Copy-Item "$env:RECIPE_DIR\activate-sirf.bat" "$env:PREFIX\etc\conda\activate.d\sirf-activate.bat"
