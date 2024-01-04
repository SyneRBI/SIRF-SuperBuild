#!/usr/bin/env bash
set -exuo pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")"
git submodule update --init --recursive

cd docker-stacks/images/docker-stacks-foundation
docker build --build-arg PYTHON_VERSION=3.9 --build-arg ROOT_CONTAINER=ubuntu:22.04 -t synerbi/jupyter:foundation-cpu .
docker build --build-arg PYTHON_VERSION=3.9 --build-arg ROOT_CONTAINER=nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu22.04 -t synerbi/jupyter:foundation-gpu .

for ver in cpu gpu; do
  cd ../base-notebook
  docker build --build-arg BASE_CONTAINER=synerbi/jupyter:foundation-${ver} -t synerbi/jupyter:base-${ver} .

  cd ../minimal-notebook
  docker build --build-arg BASE_CONTAINER=synerbi/jupyter:base-${ver} -t synerbi/jupyter:minimal-${ver} .

  cd ../scipy-notebook
  docker build --build-arg BASE_CONTAINER=synerbi/jupyter:minimal-${ver} -t synerbi/jupyter:scipy-${ver} .
done

cd ../../../..
SIRF_BUILD_ARGS=(
  build .
  --build-arg EXTRA_BUILD_FLAGS="-DGadgetron_TAG=6202fb7352a14fb82817b57a97d928c988eb0f4b -DISMRMRD_TAG=v1.13.7 -Dsiemens_to_ismrmrd_TAG=v1.2.11"
)
SIRF_CPU_BUILD_ARGS=(
  --build-arg BASE_CONTAINER=synerbi/jupyter:scipy-cpu
  --build-arg Gadgetron_USE_CUDA=OFF
)
SIRF_GPU_BUILD_ARGS=(
  --build-arg BASE_CONTAINER=synerbi/jupyter:scipy-gpu
  --build-arg Gadgetron_USE_CUDA=ON
)
# build
docker "${SIRF_BUILD_ARGS[@]}" "${SIRF_CPU_BUILD_ARGS[@]}" --target build -t synerbi/jupyter:sirf-build-cpu
docker "${SIRF_BUILD_ARGS[@]}" "${SIRF_GPU_BUILD_ARGS[@]}" --target build -t synerbi/jupyter:sirf-build-gpu
# install
docker "${SIRF_BUILD_ARGS[@]}" "${SIRF_CPU_BUILD_ARGS[@]}" -t synerbi/sirf:jupyter
docker "${SIRF_BUILD_ARGS[@]}" "${SIRF_GPU_BUILD_ARGS[@]}" -t synerbi/sirf:jupyter-gpu
# ccache
sudo rm -r ./docker/devel/.ccache/*
for ver in cpu gpu; do
  docker run --rm -it -v ./docker/devel/.ccache:/ccache synerbi/jupyter:sirf-build-${ver} bash -c 'cp -r /opt/ccache/* /ccache/'
done

popd
