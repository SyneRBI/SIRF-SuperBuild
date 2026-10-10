# SIRF 3.10.1 (Windows) - C++ + Python, cGadgetron GADGETRON_USE_CUDA=OFF default.
# Gadgetron & ISMRMRD come from the sibling conda outputs (%LIBRARY_PREFIX%)
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
# same conda host/build env fix as build-gadgetron.ps1
$gadgetron_cuda = if ($env:GADGETRON_USE_CUDA) { $env:GADGETRON_USE_CUDA } else { "OFF" }
if ($gadgetron_cuda -eq "ON") {
    $env:CUDA_TOOLKIT_ROOT_DIR = $env:PREFIX
    $env:CUDA_ROOT = $env:PREFIX
    $env:CUDA_INC_PATH = $env:LIBRARY_PREFIX
    $env:CUDA_LIB_PATH = $env:LIBRARY_PREFIX
    $env:PATH = "$env:BUILD_PREFIX\Library\nvvm\bin;" + $env:PATH
}
cmake -G Ninja $env:SRC_DIR -B "$env:BUILD_PREFIX\build" "-DCMAKE_BUILD_TYPE=Release" "-DCMAKE_INSTALL_PREFIX=$env:PREFIX" "-DCMAKE_PREFIX_PATH=$env:LIBRARY_PREFIX;$env:PREFIX" "-DRUN_ISMRMRD_SHEPP_LOGAN:BOOL=OFF" "-DDOWNLOAD_ZENODO_TEST_DATA:BOOL=ON" "-DDISABLE_Matlab:BOOL=ON" "-DDISABLE_PYTHON:BOOL=OFF" "-DPython_EXECUTABLE=$env:PREFIX\python.exe" "-DPYTHON_DEST_DIR=$env:SP_DIR" "-DDISABLE_Registration:BOOL=OFF" "-DDISABLE_Gadgetron:BOOL=OFF" "-DGadgetron_USE_CUDA:BOOL=$gadgetron_cuda"
Assert-Zero "cmake configure"
cmake --build "$env:BUILD_PREFIX\build" --config Release
Assert-Zero "cmake build"
cmake --install "$env:BUILD_PREFIX\build" --config Release
Assert-Zero "cmake install"

# SIRF-Contribs (pure-Python, sirf.contrib) is now built as a separate output
# (the sirf-contrib output in recipe.yaml); not installed here.

# SIRF runtime env vars on activation (examples_data_path, Gadgetron relay)
New-Item -ItemType Directory -Force "$env:PREFIX\etc\conda\activate.d" | Out-Null
New-Item -ItemType Directory -Force "$env:PREFIX\etc\conda\deactivate.d" | Out-Null
foreach ($ext in @('sh','csh','fish','bat','ps1')) {
  Copy-Item "$env:RECIPE_DIR\activate-sirf.$ext" "$env:PREFIX\etc\conda\activate.d\sirf-activate.$ext"
  Copy-Item "$env:RECIPE_DIR\deactivate-sirf.$ext" "$env:PREFIX\etc\conda\deactivate.d\sirf-deactivate.$ext"
}

# --- test suite (C++ tests; the python tests run in the rattler test phase) ---
# ctest needs the build tree, so it runs here. The MR/Gadgetron tests talk to a
# live gadgetron server (relay 127.0.0.1:9002) and, for CUDA builds, to a GPU;
# skip them for CUDA builds without a GPU (standard CI runners).
$server_tests = $true
if ($gadgetron_cuda -eq "ON") {
    $nvidia = Get-Command nvidia-smi -ErrorAction SilentlyContinue
    if (-not $nvidia) { $server_tests = $false }
    else { & nvidia-smi -L *> $null; if ($LASTEXITCODE -ne 0) { $server_tests = $false } }
}
$exclude = '_PYTHON|_DEMOS'
if (-not $server_tests) { $exclude += '|MR_|GADGETRON' }
$ctest_args = @("--test-dir", "$env:BUILD_PREFIX\build", "--verbose", "--output-on-failure", "-E", $exclude)

$gadgetron_pid = $null
if ($server_tests) {
    $gadgetron_pid = Start-Process -FilePath "$env:PREFIX\Library\bin\gadgetron.exe" `
        -RedirectStandardOutput "$env:BUILD_PREFIX\gadgetron.log" `
        -RedirectStandardError "$env:BUILD_PREFIX\gadgetron-err.log" -PassThru
    # wait for the relay port (up to 60s)
    for ($i = 0; $i -lt 60; $i++) {
        $c = New-Object Net.Sockets.TcpClient
        try { $c.Connect("127.0.0.1", 9002); $c.Close(); break } catch { Start-Sleep -Seconds 1 }
    }
}
$env:GADGETRON_HOME = $env:PREFIX  # relay config lookup, cf. sirf-activate.bat
ctest @ctest_args
$test_fail = $LASTEXITCODE
if ($gadgetron_pid) { Stop-Process -Id $gadgetron_pid.Id -Force -ErrorAction SilentlyContinue }
if ($test_fail -ne 0) {
    Write-Host "----------- Last 70 lines of gadgetron.log"
    Get-Content "$env:BUILD_PREFIX\gadgetron.log" -Tail 70 -ErrorAction SilentlyContinue
    exit $test_fail
}

# The example data ships in the separate (optional) sirf-data package; strip the copy
# the CMake installed so it isn't duplicated into the sirf package.
Remove-Item -Recurse -Force "$env:PREFIX\share\SIRF-*\data" -ErrorAction SilentlyContinue

