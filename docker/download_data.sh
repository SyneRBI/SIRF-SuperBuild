#! /bin/bash

INSTALL_DIR=${1:-/devel}

# download the SIRF-Exercises data
cd $INSTALL_DIR
[ -d SIRF-Exercises ] || cp -a $SIRF_PATH/../../../SIRF-Exercises .
for i in SIRF-Exercises/scripts/download_*.sh; do ./$i $PWD; done

