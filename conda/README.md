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

See the top of [recipe.yaml](./recipe.yaml) for invocation.

## install

```sh
rattler-build publish output/*64/*.conda --to ./channel
# install in sirf env
conda create -n sirf python -c file://$PWD/channel -c conda-forge -c ismrmrd -c ccpi -c synerbi sirf siemens_to_ismrmrd
conda activate sirf
```

## Notes

- `-c channel` order matters
- `-v` for verbose build output
- disable ccache:
  ```sh
  CMAKE_CXX_COMPILER_LAUNCHER="" CMAKE_C_COMPILER_LAUNCHER="" rattler-build ...
  ```
