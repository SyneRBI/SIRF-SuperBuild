# Gadgetron 4.7.2 (SyneRBI fork, Windows) - USE_CUDA=OFF default
$ErrorActionPreference = "Stop"

# PowerShell 5.1 does not treat native exit codes as errors, so check them explicitly.
function Assert-Zero($msg) { if ($LASTEXITCODE -ne 0) { throw "$msg failed with exit code $LASTEXITCODE" } }

# boost 1.92's hana struct_macros.hpp defines BOOST_HANA_PP_NARG_IMPL with 202
# parameters; MSVC's hard limit is 127 (C1112) at #define time, so any TU that
# includes <boost/hana/...> fails. Gadgetron defines accessors_impl directly and
# never uses the hana dispatch macros, so replace the header in the build env
# with the same file truncated to 55 members.
$hana = Join-Path $env:LIBRARY_PREFIX "Library\include\boost\hana\detail\struct_macros.hpp"
if (-not (Test-Path $hana)) { $hana = Join-Path $env:LIBRARY_PREFIX "include\boost\hana\detail\struct_macros.hpp" }
Copy-Item "$env:SRC_DIR\cmake\hana-struct-macros-55.hpp" $hana -Force

# headers/imports: host cuda-*-dev (%LIBRARY_PREFIX%\include, %LIBRARY_PREFIX%\lib\x64)
# nvcc/cicc (under Library\nvvm\bin since CUDA 12.6): build cuda-nvcc.
$use_cuda = if ($env:USE_CUDA) { $env:USE_CUDA } else { "OFF" }
if ($use_cuda -eq "ON") {
    $env:CUDA_TOOLKIT_ROOT_DIR = $env:PREFIX
    $env:CUDA_ROOT = $env:PREFIX
    $env:CUDA_INC_PATH = $env:LIBRARY_PREFIX
    $env:CUDA_LIB_PATH = $env:LIBRARY_PREFIX
    $env:PATH = (Join-Path $env:BUILD_PREFIX "Library\nvvm\bin") + ";" + $env:PATH
}

cmake -G Ninja $env:SRC_DIR -B "$env:BUILD_PREFIX\build" "-DCMAKE_BUILD_TYPE=Release" "-DCMAKE_INSTALL_PREFIX=$env:LIBRARY_PREFIX" "-DCMAKE_PREFIX_PATH=$env:LIBRARY_PREFIX" "-DUSE_CUDA:BOOL=$use_cuda" "-DUSE_OPENMP:BOOL=ON" "-DBUILD_PYTHON_SUPPORT:BOOL=OFF" "-DBUILD_MATLAB_SUPPORT:BOOL=OFF" "-DBUILD_TESTING:BOOL=OFF" "-DBUILD_SUPPRESS_WARNINGS:BOOL=ON" "-DDISABLE_STANDALONE_GPU_APPS:BOOL=$use_cuda"
Assert-Zero "cmake configure"
cmake --build (Join-Path $env:BUILD_PREFIX "build") --config Release
Assert-Zero "cmake build"
cmake --install (Join-Path $env:BUILD_PREFIX "build") --config Release
Assert-Zero "cmake install"
