#!/usr/bin/env bash
set -euo pipefail

print_help(){
  cat <<EOF
Creates images: synerbi/sirf:latest, synerbi/sirf:latest-gpu
Also creates intermediate (temp) images: synerbi/jupyter

Usage: $0 [options] [-- [docker compose options]]
Options:
$(sed -rn 's/^\s*(\w)\) .*;; # (.*)$/  -\1: \2/p' "$0")
Docker Compose Options:
  Forwarded to 'docker compose build/run', e.g.:
    $0 -b -- --build-arg BUILD_CIL=ON --build-arg EXTRA_BUILD_FLAGS="-DCIL_TAG=origin/master"
Detected config files:
  Dockerfile docker-compose.yml $(echo docker/docker-compose.*.yml)
EOF
}

verbose=0
build=0
run=0
devel=0
cpu=0
gpu=0
update_ccache=1
regen_ccache=0
while getopts :hvbrdcgUR option; do
  case "${option}" in
  h) print_help; exit 0 ;; # print this help
  v) verbose=1 ;; # verbose
  b) build=1 ;; # build
  r) run=1 ;; # run
  d) devel=1 ;; # use development (main/master) repo branches
  c) cpu=1 ;; # enable CPU
  g) gpu=1 ;; # enable GPU
  U) update_ccache=0 ;; # disable updating docker/devel/.ccache
  R) regen_ccache=1 ;; # regenerate (rather than append to) docker/devel/.ccache (always true if both -c and -g are specified)
  *) ;;
  esac
done
shift $((OPTIND-1)) # remove processed options

test $verbose = 1 && set -x
test $build$cpu$gpu = 111 && regen_ccache=1 # force rebuild ccache
echo "cpu: $cpu, gpu: $gpu, update ccache: $update_ccache, regen ccache: $regen_ccache, devel: $devel"

# compose binary
DCC="${DCC:-docker compose}"
which docker-compose 2>&1 >> /dev/null && DCC=$(which docker-compose)
# CPU config
DCC_CPU="$DCC -f docker-compose.yml"
test $devel = 1 && DCC_CPU+=" -f docker/docker-compose.devel.yml"
# GPU config
DCC_GPU="$DCC_CPU -f docker/docker-compose.gpu.yml"
test $devel = 1 && DCC_GPU+=" -f docker/docker-compose.devel-gpu.yml"

test $cpu$gpu = 00 && echo >&2 "WARNING: neither -c nor -g specified"
test $cpu = 1 && echo "docker compose command: $DCC_CPU"
test $gpu = 1 && echo "docker compose command: $DCC_GPU"
echo "docker compose options: $@"

pushd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" >> /dev/null
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
  test $cpu$update_ccache = 11 && $DCC_CPU up --no-build sirf-build && $DCC_CPU down sirf-build
  test $gpu$update_ccache = 11 && $DCC_GPU up --no-build sirf-build && $DCC_GPU down sirf-build
fi

if test $run = 1; then
  echo start
  export USER_ID UID
  test $cpu = 1 && $DCC_CPU up --no-build "$@" sirf; $DCC_CPU down sirf
  test $gpu = 1 && $DCC_GPU up --no-build "$@" sirf; $DCC_GPU down sirf
fi

popd >> /dev/null
