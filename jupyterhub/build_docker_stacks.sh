#! /bin/sh
set -ex

# change the base class with the ROOT_CONTAINER argument
pushd ../../docker-stacks/docker-stacks-foundation
# docker-stacks-foundations
docker build --build-arg PYTHON_VERSION=3.9 --build-arg ROOT_CONTAINER=nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04 -t paskino/jupyter:docker-stacks-foundations-cuda11-cudnn8-devel-ubuntu22.04 .

# base notebook
cd ../base-notebook
# build and tag
docker build --build-arg BASE_CONTAINER=paskino/jupyter:docker-stacks-foundations-cuda11-cudnn8-devel-ubuntu22.04 -t paskino/jupyter:base-notebook-cuda11-cudnn8-devel-ubuntu22.04 .

# minimal notebook
cd ../minimal-notebook
docker build --build-arg BASE_CONTAINER=paskino/jupyter:base-notebook-cuda11-cudnn8-devel-ubuntu22.04 -t paskino/jupyter:minimal-notebook-cuda11-cudnn8-devel-ubuntu22.04 .


# scipy-notebook
cd ../scipy-notebook
docker build --build-arg BASE_CONTAINER=paskino/jupyter:minimal-notebook-cuda11-cudnn8-devel-ubuntu22.04 -t paskino/jupyter:scipy-notebook-cuda11-cudnn8-devel-ubuntu22.04 .

# datascience-notebook
cd ../datascience-notebook
docker build --build-arg BASE_CONTAINER=paskino/jupyter:scipy-notebook-cuda11-cudnn8-devel-ubuntu22.04 -t paskino/jupyter:datascience-notebook-cuda11-cudnn8-devel-ubuntu22.04 .

popd