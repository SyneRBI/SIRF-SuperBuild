#!/usr/bin/env bash
set -exuo pipefail

git submodule update --init --recursive
pushd $(dirname "$0")/docker-stacks/images/docker-stacks-foundation

docker build --build-arg PYTHON_VERSION=3.9 --build-arg BASE_CONTAINER=nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu22.04 -t synerbi/jupyter:foundation .

cd ../base-notebook
docker build --build-arg BASE_CONTAINER=synerbi/jupyter:foundation -t synerbi/jupyter:base .

cd ../minimal-notebook
docker build --build-arg BASE_CONTAINER=synerbi/jupyter:base -t synerbi/jupyter:minimal .


cd ../scipy-notebook
docker build --build-arg BASE_CONTAINER=synerbi/jupyter:minimal -t synerbi/jupyter:scipy .

cd ../datascience-notebook
docker build --build-arg BASE_CONTAINER=synerbi/jupyter:scipy -t synerbi/jupyter:datascience .

popd

docker build --build-arg BASE_CONTAINER=synerbi/jupyter:datascience -t synerbi/jupyter:sirf -f jupyterhub/Dockerfile .
