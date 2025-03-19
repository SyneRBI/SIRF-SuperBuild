#! /bin/bash
# Functions used by the UPDATE script and update_VM.sh for the SyneRBI VM.
# This file needs to be "sourced".

# Warning: if you use a local branch (as opposed to a remote branch or a tag), this
# script will merge remote updates automatically, without asking.
#
# Authors: Kris Thielemans, Evgueni Ovtchinnikov, Edoardo Pasca,
# Casper da Costa-Luis
# Copyright 2016-2022, 2024 University College London
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

# print usage
# takes script name as first and only argument
print_usage(){
  echo "Usage: $1 [-t tag] [-j n] [-s] [-D] [-S]"
  echo "User options:"
  echo "- Use the -j option to change the number of parallel builds from the default ${num_parallel}"
  echo "- Use the -s option to update and install necessary system and Python components."
  echo "   We recommend to do this once when upgrading between major versions."
  echo "Developer options:"
  echo "- Use the -t tag option to checkout a specific version of the SIRF-SuperBuild."
  echo "   Otherwise the most recent release will be used."
  echo "- Use the -D option to set DEVEL_BUILD=ON."
  echo "- Use the -S option to skip the building itself (i.e. just run CMake configure."
  echo ""
  echo "We recommend to remove all previously installed files before running this script:"
  echo "   rm -rf ~/devel/install/lib ~/devel/install/include"
  echo "If you experience problems, you could even remove previous build files:"
  echo "   rm -rf ~/devel/buildVM/"
}

# process any options and set env variables
# takes script name as first argument and options as the remaining ones
process_options(){
  script_name="$1"
  shift

  SB_build=1
  SB_repo=https://github.com/SyneRBI/SIRF-SuperBuild.git
  SB_TAG='default'
  num_parallel=2
  update_remote=0
  apt_install=0
  DEVEL_BUILD=OFF
  while getopts hrsSDt:j: option
   do
   case "${option}"
   in
    r) update_remote=1;;
    s) apt_install=1;;
    R) SB_REPO=$OPTARG;;
    t) SB_TAG=$OPTARG;;
    D) DEVEL_BUILD=ON;;
    S) SB_build=0;;
    j) num_parallel=$OPTARG;;
    h)
     print_usage "$script_name"
     exit 0
     ;;
    *)
     echo "Wrong option passed. Use the -h option to get some help." >&2
     exit 1
    ;;
   esac
  done
  # get rid of processed options
  shift $((OPTIND-1))

  if [ $# -ne 0 ]
  then
    echo "Wrong command line format. Use the -h option to get some help." >&2
    exit 1
  fi
}

# set various environment variables
initialise_environment(){

  if [ -r ~/.sirfrc ]; then
    source ~/.sirfrc
  fi

  # check current version (if any) to take into account later on
  # (the new VM version will be saved at the end of the script)
  if [ -r ~/.sirf_VM_version ]; then
    source ~/.sirf_VM_version
  else
    if [ -r /usr/local/bin/update_VM.sh ]
    then
      # we are on the very first VM
      echo '======================================================'
      echo 'You have a very old VM. Aborting'
      echo '======================================================'
      exit 1
    else
      if [ -r ~/.sirfrc ]; then
        SIRF_VM_VERSION=0.9
        echo '======================================================'
        if [ $apt_install == 1 ]; then
          echo 'You have a very old VM. This update might fail.'
          echo 'You probably will have to "rm -rf ~/devel/buildVM" first.'
        else
          echo 'You have a very old VM. You have to run with -s (but the update might fail anyway).'
          exit 1
        fi
        echo '======================================================'
      else
        SIRF_VM_VERSION=new_VM
      fi
    fi
  fi

  # location of sources
  if [ -z $SIRF_SRC_PATH ]
  then
    export SIRF_SRC_PATH=~/devel
  fi

  SIRF_INSTALL_PATH=$SIRF_SRC_PATH/install

}

# SuperBuild software (checkout appropriate version)
SuperBuild_git_update(){
  echo "==================== SuperBuild checkout ====================="
  cd $SIRF_SRC_PATH
  if [ ! -d SIRF-SuperBuild ]
  then
    git clone $SB_repo
    cd SIRF-SuperBuild
  else
    cd SIRF-SuperBuild
    git fetch --tags --all
  fi
  # go to SB_TAG
  if [ $1 = 'default' ]
  then
   # get the latest tag matching v
   #SB_TAG=`git fetch; git for-each-ref refs/tags/v* --sort=-taggerdate --format='%(refname:short)' --count=1`
   SB_TAG=`git tag | xargs -I@ git log --format=format:"%at @%n" -1 @ | sort | awk '{print $2}' | tail -1`
  else
   SB_TAG=$1
  fi
  clone_or_pull $SB_repo $SB_TAG
  cd ..
}

# SuperBuild cmake
SuperBuild_install(){
  echo "==================== SuperBuild cmake/make ====================="
  cd $SIRF_SRC_PATH
  buildVM=buildVM
  mkdir -p $buildVM

  cd $buildVM
  cmake -S ../SIRF-SuperBuild -B . \
        -DCMAKE_INSTALL_PREFIX="$SIRF_INSTALL_PATH" \
        -U\*_URL -U\*_TAG \
        -DUSE_SYSTEM_SWIG=On \
        -DUSE_SYSTEM_Boost=On \
        -DUSE_SYSTEM_Armadillo=On \
        -DUSE_SYSTEM_FFTW3=On \
        -DUSE_SYSTEM_HDF5=ON \
        -DBUILD_siemens_to_ismrmrd=On \
        -DUSE_ITK=ON \
        -DDEVEL_BUILD="$DEVEL_BUILD" \
        -DNIFTYREG_USE_CUDA=OFF\
        -DBUILD_CIL=ON\
        -DPython_EXECUTABLE="$PYTHON_EXECUTABLE"\
        -DPython3_EXECUTABLE="$PYTHON_EXECUTABLE"\
        -DBUILD_pet_rd_tools=ON
  if [ "$SB_build" = 1 ]
  then
    cmake --build . -j"$num_parallel"
   fi
}

# define a function to get the source
# arguments: name_of_repo [git_ref]
clone_or_pull()
{
  repoURL=$1
  repo=`basename $1`
  repo=${repo/.git//}
  git_ref=${2:-master} # default to master
  echo "======================  Getting/updating source for $repo"
  cd $SIRF_SRC_PATH
  if [ -d $repo ]
  then
    cd $repo
    if [ $update_remote == 1 ]; then
        git remote set-url origin $repoURL
    fi
    git fetch --tags --all
  else
    git clone --recursive $repoURL
    cd $repo
  fi
  git checkout $git_ref
  # check if we are not in detached HEAD state
  if git symbolic-ref -q HEAD
  then
      # We are on a local branch.
      echo "Warning: updating your local branch with 'git pull'"
      git pull
  fi
  git submodule update --init
}

# define a function to build and install
# arguments: name_of_repo [cmake arguments]
build_and_install()
{
  repo=$1
  shift
  echo "======================  Building $repo"
  cd $BUILD_PATH
  if [ -d $repo ]
  then
    cd $repo
    cmake .
  else
    mkdir $repo
    cd $repo
    cmake $* $SIRF_SRC_PATH/$repo
  fi
  echo "======================  Installing $repo"
  make -j${num_parallel} install
}

# function to do everything
update()
{
  clone_or_pull $1
  build_and_install $*
}
