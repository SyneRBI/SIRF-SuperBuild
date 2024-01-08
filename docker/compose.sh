#!/usr/bin/env bash
set -euo pipefail

build_cpu=1
build_gpu=1
run_cpu=0
run_gpu=0
while getopts :hCGcg option; do
  case "${option}" in
  h) cat <<EOF
Creates images: synerbi/sirf:jupyter, synerbi/sirf:jupyter-gpu
Also creates intermediate (temp) images: synerbi/jupyter
Usage: $0 [-hCGcg] [-- [build options]]
  -h: print this help
  -C: disable CPU build
  -G: disable GPU build
  -c: start CPU container
  -g: start GPU container
  build options: passed to 'docker compose build'
EOF
      exit 0 ;;
  C) build_cpu=0 ;;
  G) build_gpu=0 ;;
  c) run_cpu=1 ;;
  g) run_gpu=1 ;;
  *) ;;
  esac
done
# remove processed options
shift $((OPTIND-1))

echo "build_cpu: $build_cpu, build_gpu: $build_gpu, run_cpu: $run_cpu, run_gpu: $run_gpu"
echo "build args: $@"

DCC_CPU="docker compose"
DCC_GPU="docker compose -f docker-compose.yml -f docker/docker-compose.gpu.yml"

pushd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")"
git submodule update --init --recursive

echo build ccache
test $build_cpu = 1 && $DCC_CPU build "$@" sirf-build
test $build_gpu = 1 && $DCC_GPU build "$@" sirf-build

echo build
test $build_cpu = 1 && $DCC_CPU build "$@"
test $build_gpu = 1 && $DCC_GPU build "$@"

echo copy ccache
test $build_cpu$build_gpu = 11 && sudo rm -r ./docker/devel/.ccache/*
export USER_ID UID
test $build_cpu = 1 && $DCC_CPU up sirf-build
test $build_gpu = 1 && $DCC_GPU up sirf-build

echo start
test $run_cpu = 1 && $DCC_CPU up -d sirf
test $run_gpu = 1 && $DCC_GPU up -d sirf

popd
