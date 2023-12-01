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
docker build --build-arg BASE_CONTAINER=synerbi/jupyter:datascience --build-arg SIRF_IMAGE=${SIRF_IMAGE} -t synerbi/jupyter:sirf -f jupyterhub/Dockerfile .

popd
