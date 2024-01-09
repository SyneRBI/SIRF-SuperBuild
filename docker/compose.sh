#!/usr/bin/env bash
set -euo pipefail

build_cpu=1
build_gpu=1
run_cpu=0
run_gpu=0
regen_ccache=0
while getopts :hCGcgr option; do
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
  -r: regenerate (rather than append to) docker/devel/.ccache
      (default true iff neither -C nor -G are specified)
  build options: passed to 'docker compose build'
EOF
      exit 0 ;;
  C) build_cpu=0 ;;
  G) build_gpu=0 ;;
  c) run_cpu=1 ;;
  g) run_gpu=1 ;;
  r) regen_ccache=1 ;;
  *) ;;
  esac
done
# remove processed options
shift $((OPTIND-1))

test $build_cpu$build_gpu = 11 && regen_ccache = 1
echo "build_cpu: $build_cpu, build_gpu: $build_gpu, regen ccache: $regen_ccache"
echo "run_cpu: $run_cpu, run_gpu: $run_gpu"
echo "build args: $@"

DCC_CPU="docker compose"
DCC_GPU="docker compose -f docker-compose.yml -f docker/docker-compose.gpu.yml"

pushd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")"
git submodule update --init --recursive

echo build base stack
for image in foundation base minimal scipy; do
  test $build_cpu = 1 && $DCC_CPU build "$@" $image
  test $build_gpu = 1 && $DCC_GPU build "$@" $image
done

echo build ccache
test $build_cpu = 1 && $DCC_CPU build "$@" sirf-build
test $build_gpu = 1 && $DCC_GPU build "$@" sirf-build

echo build
test $build_cpu = 1 && $DCC_CPU build "$@"
test $build_gpu = 1 && $DCC_GPU build "$@"

echo copy ccache
test $regen_ccache = 1 && sudo rm -rf ./docker/devel/.ccache/*
export USER_ID UID
test $build_cpu = 1 && $DCC_CPU up sirf-build && $DCC_CPU down sirf-build
test $build_gpu = 1 && $DCC_GPU up sirf-build && $DCC_GPU down sirf-build

echo start
test $run_cpu = 1 && $DCC_CPU up -d sirf && $DCC_CPU down sirf
test $run_gpu = 1 && $DCC_GPU up -d sirf && $DCC_GPU down sirf

popd
