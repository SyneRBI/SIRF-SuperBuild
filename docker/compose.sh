#!/usr/bin/env bash
set -euo pipefail

print_help(){
  cat <<EOF
Creates images: synerbi/sirf:jupyter, synerbi/sirf:jupyter-gpu
Also creates intermediate (temp) images: synerbi/jupyter

Usage: $0 [options] [-- [docker compose options]]
Options:
  -h: print this help
  -b: build
  -r: run
  -d: use development (main/master) repo branches
  -c: enable CPU
  -g: enable GPU
  -U: disable updating docker/devel/.ccache
  -R: regenerate (rather than append to) docker/devel/.ccache
      (always true if both -c and -g are specified)
EOF
}

build=0
run=0
devel=0
cpu=0
gpu=0
update_ccache=1
regen_ccache=0
while getopts :hbrdcgUR option; do
  case "${option}" in
  h) print_help; exit 0 ;;
  b) build=1 ;;
  r) run=1 ;;
  d) devel=1 ;;
  c) cpu=1 ;;
  g) gpu=1 ;;
  U) update_ccache=0 ;;
  R) regen_ccache=1 ;;
  *) ;;
  esac
done
shift $((OPTIND-1)) # remove processed options

test $build$run = 00 && echo >&2 "WARNING: neither -b nor -r specified"
test $cpu$gpu = 00 && echo >&2 "WARNING: neither -c nor -g specified"
test $build$cpu$gpu = 111 && regen_ccache=1 # force rebuild ccache
echo "cpu: $cpu, gpu: $gpu, update ccache: $update_ccache, regen ccache: $regen_ccache, devel: $devel"
echo "docker compose options: $@"

DCC_CPU="docker compose -f docker-compose.yml"
DCC_GPU="$DCC_CPU -f docker/docker-compose.gpu.yml"
test $devel = 1 && DCC_CPU+=" -f docker/docker-compose.devel.yml"
test $devel$gpu = 11 && echo >&2 "WARNING: devel gpu not supported"

pushd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")"
git submodule update --init --recursive

if test $build = 1; then
  echo build base stack
  for image in foundation base minimal scipy; do
    test $cpu = 1 && $DCC_CPU build "$@" $image
    test $gpu = 1 && $DCC_GPU build "$@" $image
  done

  echo build ccache
  test $cpu = 1 && $DCC_CPU build "$@" sirf-build
  test $gpu = 1 && $DCC_GPU build "$@" sirf-build

  echo build
  test $cpu = 1 && $DCC_CPU build "$@"
  test $gpu = 1 && $DCC_GPU build "$@"

  echo copy ccache
  test $update_ccache$regen_ccache = 11 && sudo rm -rf ./docker/devel/.ccache/*
  export USER_ID UID
  test $cpu = 1 && $DCC_CPU up --no-build sirf-build && test $update_ccache = 1 && $DCC_CPU down sirf-build
  test $gpu = 1 && $DCC_GPU up --no-build sirf-build && test $update_ccache = 1 && $DCC_GPU down sirf-build
fi

if test $run = 1; then
  echo start
  export USER_ID UID
  test $cpu = 1 && $DCC_CPU up --no-build "$@" sirf; $DCC_CPU down sirf
  test $gpu = 1 && $DCC_GPU up --no-build "$@" sirf; $DCC_GPU down sirf
fi

popd
