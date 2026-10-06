# SIRF conda package

## prerequisites

```sh
conda install conda-forge::rattler-build python=3.13
git clone https://github.com/SyneRBI/SIRF-SuperBuild --branch rattler
cd SIRF-SuperBuild
```

## rattler-build (with ccache)

- Platforms: `linux-64`, `osx-arm64`, `win-64`
- CUDA: `None` (CPU), `12.9`, `13.4`
- Python: `3.11`, `3.12`, `3.13`

### CPU-only
One of these depending on OS:
```sh
rattler-build build -r conda -c conda-forge -c ismrmrd -c ccpi --no-build-id --target-platform linux-64 --variant python=3.13
rattler-build build -r conda -c conda-forge -c ismrmrd -c ccpi --no-build-id --target-platform osx-arm64 --variant python=3.13
rattler-build build -r conda -c conda-forge -c ismrmrd -c ccpi --no-build-id --target-platform win-64 --variant python=3.13
```
### CUDA 13.4
```sh
rattler-build build -r conda --variant cuda_compiler_version=13.4 -c conda-forge -c ismrmrd -c ccpi --no-build-id --target-platform linux-64 --variant python=3.13
rattler-build build -r conda --variant cuda_compiler_version=13.4 -c conda-forge -c ismrmrd -c ccpi --no-build-id --target-platform win-64 --variant python=3.13
```
### CUDA 12.9
```sh
rattler-build build -r conda --variant cuda_compiler_version=12.9 -c conda-forge -c ismrmrd -c ccpi --no-build-id --target-platform linux-64 --variant python=3.13
rattler-build build -r conda --variant cuda_compiler_version=12.9 -c conda-forge -c ismrmrd -c ccpi --no-build-id --target-platform win-64 --variant python=3.13
```

> [!TIP]
> disable ccache:
> ```sh
> CMAKE_CXX_COMPILER_LAUNCHER="" CMAKE_C_COMPILER_LAUNCHER="" rattler-build ...
> ```

## install

```sh
rattler-build publish output/*64/*.conda --to ./channel
# install in sirf env
conda create -n sirf python=3.13 -c file://$PWD/channel -c conda-forge -c ismrmrd -c ccpi sirf siemens_to_ismrmrd
conda activate sirf
```

## Notes

- `-c channel` order matters
- `-v` for verbose build output
- disable ccache:
  ```sh
  CMAKE_CXX_COMPILER_LAUNCHER="" CMAKE_C_COMPILER_LAUNCHER="" rattler-build ...
  ```
