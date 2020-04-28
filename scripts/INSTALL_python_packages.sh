#! /bin/bash

# Script to install Python packages for SIRF via pip.
#
# Authors: Kris Thielemans
# Copyright 2018 University College London
#
# This is software developed for the Collaborative Computational
# Project in Positron Emission Tomography and Magnetic Resonance imaging
# (http://www.ccppetmr.ac.uk/).

#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0.txt
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#=========================================================================

prog=$0
print_usage()
{
    echo "Upgrades pip and installs some Python packages needed by SIRF."
    echo "Usage:"
    echo "   `basename $prog` --help"
    echo "   `basename $prog` --python 'python-command' [pip-install-options ...]"
    echo 'Default Python is $SIRF_PYTHON_EXECUTABLE if it is set or python otherwise.'
    echo "Any options (aside from --help and --python) are passed to the 'pip install' commands."
}

set -e
# give a sensible error message (note: works only in bash)
trap 'echo An error occurred in $0 at line $LINENO. Current working-dir: $PWD' ERR

# default python version
if [ -z "$SIRF_PYTHON_EXECUTABLE" ]
then
    PYTHON=python
else
    PYTHON=$SIRF_PYTHON_EXECUTABLE
fi

PIPOPTIONS=""

while (( "$#" )); do
  case "$1" in
    --python)
      PYTHON=$2
      shift 2
      ;;
    --help)
      print_usage
      exit 0
      ;;
    *)
      PIPOPTIONS="$PIPOPTIONS $1"
      shift
      ;;
  esac
done

$PYTHON -m pip install $PIPOPTIONS --upgrade pip wheel setuptools
$PYTHON -m pip install $PIPOPTIONS --only-binary=numpy,scipy,matplotlib numpy scipy matplotlib nose coverage docopt deprecation nibabel pytest
$PYTHON -m pip install $PIPOPTIONS jupyter spyder==3.2
$PYTHON -m pip uninstall $PIPOPTIONS -y spyder-kernels
# CIL
$PYTHON -m pip install $PIPOPTIONS pillow==5
