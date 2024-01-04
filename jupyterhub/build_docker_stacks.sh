#!/usr/bin/env bash
set -exuo pipefail

# set default sirf image
#: ${SIRF_IMAGE:=synerbi/sirf:latest}
SIRF_IMAGE="${1:-synerbi/sirf:latest}"

pushd "$(dirname "${BASH_SOURCE[0]}")"
git submodule update --init --recursive

cd docker-stacks/images/docker-stacks-foundation
docker build --build-arg PYTHON_VERSION=3.9 --build-arg BASE_CONTAINER=nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu22.04 -t synerbi/jupyter:foundation .

cd ../base-notebook
docker build --build-arg BASE_CONTAINER=synerbi/jupyter:foundation -t synerbi/jupyter:base .

cd ../minimal-notebook
docker build --build-arg BASE_CONTAINER=synerbi/jupyter:base -t synerbi/jupyter:minimal .

cd ../scipy-notebook
docker build --build-arg BASE_CONTAINER=synerbi/jupyter:minimal -t synerbi/jupyter:scipy .

cd ../datascience-notebook
docker build --build-arg BASE_CONTAINER=synerbi/jupyter:scipy -t synerbi/jupyter:datascience .

cd ../../../..
SIRF_BUILD_ARGS=(
  --build-arg BASE_CONTAINER=synerbi/jupyter:datascience -f jupyterhub/Dockerfile .
  --build-arg Gadgetron_USE_CUDA=ON
  --build-arg BUILD_CIL=OFF
  --build-arg USE_SYSTEM_Boost=OFF
)
# ccache build
docker build -t synerbi/sirf:jupyter-build --target build "${SIRF_BUILD_ARGS[@]}"
docker run --rm -it -v ./docker/devel/.ccache:/opt/ccache synerbi/sirf:jupyter-build echo copied ccache
# full build
docker build -t synerbi/sirf:jupyter "${SIRF_BUILD_ARGS[@]}"

popd
