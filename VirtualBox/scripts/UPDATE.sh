#!/bin/bash
#
# Script to install/update the SyneRBI VM. It could also be used for any
# other system but will currently change your .bashrc.
# This is to be avoided later on.
#
# Check the process_options function in UPDATE_functions.sh for usage.
#
# Warning: if you use a local branch (as opposed to a remote branch or a tag), this
# script will merge remote updates automatically, without asking.
#
# See also update_VM.sh. That script is the one you would normally call.
# Calling the current script is only safe to create a new SIRF-SuperBuild.
#
# Authors: Kris Thielemans, Evgueni Ovtchinnikov, Edoardo Pasca,
# Casper da Costa-Luis
# Copyright 2016-2022 University College London
# Copyright 2016-2022 Rutherford Appleton Laboratory STFC
#
# This is software developed for the Collaborative Computational
# Project in Synergistic Reconstruction for Biomedical Imaging (formerly PETMR)
# (http://www.ccpsynerbi.ac.uk/).

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

# Exit if something goes wrong
set -e
# give a sensible error message (note: works only in bash)
trap 'echo An error occurred in $0 at line $LINENO. Current working-dir: $PWD' ERR

# first import some functions definitions
script_loc="$(dirname -- "$(readlink -f "${BASH_SOURCE}")")"
source "${script_loc}/UPDATE_functions.sh"

# process command line options
process_options $0 $*

# set environment variables from files, defaults etc
initialise_environment

if [ ! -r ~/.sirfrc ]; then
  if [ ! -e ~/.bashrc ]
  then 
    touch ~/.bashrc
  fi
  #added=`grep -c "source ~/.sirfrc" ~/.bashrc`
  added=`cat ~/.bashrc | gawk 'BEGIN{v=0;} {if ($0 == "source ~/.sirfrc") v=v+1;} END{print v}'`
  if [ $added -eq "0" ] 
  then
    echo "I will create a ~/.sirfrc file and source this from your .bashrc"
    echo "source ~/.sirfrc" >> ~/.bashrc
  else
  echo "source ~/.sirfrc already present $added times in .bashrc. Not adding"
  fi
fi

if [ ! -d $SIRF_SRC_PATH ]; then
  mkdir -p $SIRF_SRC_PATH
fi

# old VM repos
if [ -d $SIRF_SRC_PATH/CCPPETMR_VM ]; then
    echo '======================================================'
    echo "$SIRF_SRC_PATH/CCPPETMR_VM is no longer used. We recommend removing it."
    echo '======================================================'
fi
if [ -d $SIRF_SRC_PATH/SyneRBI_VM ]; then
    echo '======================================================'
    echo "$SIRF_SRC_PATH/SyneRBI_VM is no longer used. We recommend removing it."
    echo '======================================================'
fi

# Remove old installed STIR version
# See https://github.com/SyneRBI/SIRF-SuperBuild/issues/869
rm -rf "$SIRF_INSTALL_PATH"/include/stir
rm -f "$SIRF_INSTALL_PATH"/lib/STIR*.cmake

# Checkout correct version of the SuperBuild
SuperBuild_git_update "$SB_TAG"

# Optionally install/update pre-requisites
if [ $apt_install == 1 ]; then
  cd "$SIRF_SRC_PATH"/SIRF-SuperBuild/VirtualBox/scripts
  sudo -H ./INSTALL_prerequisites_with_apt-get.sh
  sudo -H ./INSTALL_CMake.sh
fi

# best to use full path for python3
PYTHON_EXECUTABLE=$(which python3)
if which python3; then
  PYTHON_EXECUTABLE=$(which python3)
else
  PYTHON_EXECUTABLE=$(which python)
fi

# Add ~/.local/bin (or whatever it has to be) to the PATH as this is where pip installs executables
PY_USER_BIN=`"$PYTHON_EXECUTABLE" -c 'import site; import os; print ( os.path.join(site.USER_BASE , "bin") )'`
export PATH=${PY_USER_BIN}:${PATH}

# Optionally install/update python packages
if [ $apt_install == 1 ]; then
  ./INSTALL_python_packages.sh --python "$PYTHON_EXECUTABLE"
fi

# ignore notebook keys, https://github.com/CCPPETMR/SIRF-Exercises/issues/20
"$PYTHON_EXECUTABLE" -m pip install -U --user nbstripout
git config --global filter.nbstripout.extrakeys '
  metadata.celltoolbar metadata.language_info.codemirror_mode.version
  metadata.language_info.pygments_lexer metadata.language_info.version'


# Launch the SuperBuild
SuperBuild_install

# copy scripts into the path
cp -vp $SIRF_SRC_PATH/SIRF-SuperBuild/VirtualBox/scripts/update*sh $SIRF_INSTALL_PATH/bin

# install the SIRF-Exercises
cd $SIRF_SRC_PATH
clone_or_pull  https://github.com/SyneRBI/SIRF-Exercises.git
cd $SIRF_SRC_PATH/SIRF-Exercises
# Python (runtime)
if [ -f requirements.txt ]; then
  "$PYTHON_EXECUTABLE" -m pip install -U -r requirements.txt
fi
nbstripout --install

# check STIR-exercises
cd $SIRF_SRC_PATH
if [ -d STIR-exercises ]; then
  cd STIR-exercises
  git pull
fi

if [ -r ~/.sirfc ]; then
  echo "Moving existing ~/.sirfc to a backup copy"
  mv -v ~/.sirfc ~/.sirfc.old
fi
echo "export SIRF_SRC_PATH=$SIRF_SRC_PATH" > ~/.sirfrc
echo "source ${SIRF_INSTALL_PATH}/bin/env_sirf.sh" >> ~/.sirfrc
# add local python-bin to PATH
echo "export PATH=${PY_USER_BIN}:\${PATH}" >> ~/.sirfrc
echo "export EDITOR=nano" >> ~/.sirfrc
if [ ! -z "$STIR_exercises_PATH" ]; then
    echo "export STIR_exercises_PATH=$SIRF_SRC_PATH/STIR-exercises" >> ~/.sirfrc
fi

version=`echo -n "export SIRF_VM_VERSION=" | cat - ${SIRF_SRC_PATH}/SIRF-SuperBuild/VirtualBox/VM_version.txt`
echo $version > ~/.sirf_VM_version

echo ""
echo "SIRF update done!"
echo "Contents of your .sirfrc is now as follows"
echo "=================================================="
cat ~/.sirfrc
echo "=================================================="
echo "This file is sourced from your .bashrc."
echo "Close your terminal and re-open a new one to update your environment variables"
