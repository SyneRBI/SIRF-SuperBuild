# SIRF Docker image

The image contains SIRF & all dependencies required by JupyterHub.

## Usage

```sh
# CPU version
docker run --rm -it -p 8888:8888 synerbi/sirf:jupyter
# GPU version
docker run --rm -it -p 8888:8888 --gpus all synerbi/sirf:jupyter-gpu
```

To make the container user same as host user (useful when sharing folders), use `--user` and `--group-add`:

```sh
docker run --rm -it -p 8888:8888 --user $(id -u) --group-add users -v ./docker/devel:/home/jovyan/work synerbi/sirf:jupyter
```

More config: https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html#user-related-configurations

## Build the image

We use an NVIDIA CUDA Ubuntu 22.04 base image (for [CIL](https://github.com/TomographicImaging/CIL) GPU features), build https://github.com/jupyter/docker-stacks `datascience-notebook` on top, and then install SIRF & its depdendencies.

The strategy is:

1. Use a recent Ubuntu CuDNN runtime image from https://hub.docker.com/r/nvidia/cuda as base
2. Build https://github.com/jupyter/docker-stacks/tree/main/images/datascience-notebook on top
3. Copy & run the SIRF `docker/build_*.sh` scripts
4. Copy the SIRF installation directories from the `synerbi/sirf:latest` image
5. Install CIL (via `conda`)

All of this is done by [`build_docker_stacks.sh`](./build_docker_stacks.sh).

### More info

https://github.com/jupyter/docker-stacks is used to gradually build up images:

- `BASE_CONTAINER=nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04`
- `docker-stacks-foundation` -> `synerbi/jupyter:foundation`
- `base-notebook` -> `synerbi/jupyter:base`
- `minimal-notebook` -> `synerbi/jupyter:minimal`
- `scipy-notebook` -> `synerbi/jupyter:scipy`
- `datascience-notebook` -> `synerbi/jupyter:datascience`
- [`Dockerfile`](./Dockerfile) -> `synerbi/jupyter:sirf`
  + Copy & run the SIRF `build_{essential,gadgetron,system}.sh` scripts from [`../docker`](../docker)
  + Copy `/opt/SIRF-SuperBuild/{INSTALL,sources/SIRF}` directories from the `synerbi/sirf:latest` image
  + Install docker/requirements.yml
  + Clone & setup https://github.com/SyneRBI/SIRF-Exercises
  + Set some environment variables (e.g. `PYTHONPATH=/opt/SIRF-SuperBuild/INSTALL/python`, `OMP_NUM_THREADS=$(( cpu_count/2 ))`)
