# SIRF conda package

## prerequisites

```sh
conda install conda-forge::rattler-build python=3.13
git clone git@github.com/SyneRBI/SIRF-SuperBuild --branch rattler
cd SIRF-SuperBuild
```

## rattler-build (with ccache)

Targets: `linux-64`, `osx-arm64` (macOS, Apple Silicon), `win-64`. CUDA is
linux-only (`CONDA_OVERRIDE_CUDA`). `stir`/`niftyreg`/`libitk` etc. have
conda-forge builds for all three platforms, so all 5 outputs build on win & osx
(except the CUDA variant).

### CPU-only
```sh
rattler-build build -r conda -c conda-forge -c ismrmrd -c ccpi --no-build-id --target-platform linux-64 --variant python=3.13
```
### macOS (osx-arm64)
```sh
rattler-build build -r conda -c conda-forge -c ismrmrd -c ccpi --no-build-id --target-platform osx-arm64 --variant python=3.13
```
### Windows (win-64)
```sh
rattler-build build -r conda -c conda-forge -c ismrmrd -c ccpi --no-build-id --target-platform win-64 --variant python=3.13
```
### CUDA 13.0
```sh
CONDA_OVERRIDE_CUDA=13.0 rattler-build build -r conda -c nvidia --variant cuda_compiler_version=13.0 -c conda-forge -c ismrmrd -c ccpi --no-build-id --target-platform linux-64 --variant python=3.13
```
### CUDA 12.9
```sh
CONDA_OVERRIDE_CUDA=12.9 rattler-build build -r conda -c nvidia --variant cuda_compiler_version=12.9 -c conda-forge -c ismrmrd -c ccpi --no-build-id --target-platform linux-64 --variant python=3.13
```

> [!TIP]
> disable ccache:
> ```sh
> CMAKE_CXX_COMPILER_LAUNCHER="" CMAKE_C_COMPILER_LAUNCHER="" rattler-build ...
> ```

## install

```sh
rattler-build publish output/linux-64/*.conda --to ./channel
# install in sirf env
conda create -n sirf python=3.13 -c file://$PWD/channel -c conda-forge -c ismrmrd -c ccpi sirf siemens_to_ismrmrd
conda activate sirf
```

## Notes

- `-c channel` order matters
- `-v` for verbose build output
