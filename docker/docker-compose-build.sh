#!/usr/bin/env bash
# Creates images: synerbi/sirf:jupyter, synerbi/sirf:jupyter-gpu
# Also creates intermediate (temp) images: synerbi/jupyter
set -exuo pipefail

DCC_CPU=docker compose
DCC_GPU=docker compose -f docker-compose.yml -f docker/docker-compose.gpu.yml

pushd "$(dirname "${BASH_SOURCE[0]}")"
git submodule update --init --recursive

# build ccache
$DCC_CPU "$@" build sirf-build
$DCC_GPU "$@" build sirf-build
# build
$DCC_CPU "$@" build
$DCC_GPU "$@" build
# copy ccache
sudo rm -r ./docker/devel/.ccache/*
export USER_ID UID
$DCC_CPU "$@" up sirf-build
$DCC_GPU "$@" up sirf-build

popd
