# Gadgetron 4.7.2 (SyneRBI fork, Windows) - CPU only. Unix: build-gadgetron.sh.
$ErrorActionPreference = "Stop"

cmake -G Ninja $env:SRC_DIR -B (Join-Path $env:BUILD_PREFIX "build") -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$env:LIBRARY_PREFIX -DCMAKE_PREFIX_PATH=$env:LIBRARY_PREFIX -DUSE_CUDA:BOOL=OFF -DUSE_OPENMP:BOOL=ON -DBUILD_PYTHON_SUPPORT:BOOL=OFF -DBUILD_MATLAB_SUPPORT:BOOL=OFF -DBUILD_TESTING:BOOL=OFF -DBUILD_SUPPRESS_WARNINGS:BOOL=ON -DDISABLE_STANDALONE_GPU_APPS:BOOL=OFF
cmake --build (Join-Path $env:BUILD_PREFIX "build") --config Release
cmake --install (Join-Path $env:BUILD_PREFIX "build") --config Release
