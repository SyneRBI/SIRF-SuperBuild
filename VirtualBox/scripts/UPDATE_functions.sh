#
# Functions used by the UPDATE script and update_VM.sh for the SyneRBI VM.
# This file needs to be "sourced".

# Warning: if you use a local branch (as opposed to a remote branch or a tag), this
# script will merge remote updates automatically, without asking.
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

# print usage (taking script name as first argument)
print_usage(){
  echo "Usage: $1 [-t tag] [-j n] [-s]"
  echo "Use the tag option to checkout a specific version of the SIRF-SuperBuild."
  echo "   Otherwise the most recent release will be used."
  echo "Use the -j option to change the number of parallel builds from the default ${num_parallel}"
  echo "Use the -s option to update and install necessary system and Python components."
  echo "  We recommend to do this once when upgrading between major versions."
}

# SuperBuild software (checkout appropriate version)
install_SuperBuild_source(){
  echo "==================== SuperBuild checkout ====================="
  cd $SIRF_SRC_PATH
  SB_repo=https://github.com/SyneRBI/SIRF-SuperBuild.git
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
  cmake ../SIRF-SuperBuild \
        -DCMAKE_INSTALL_PREFIX=${SIRF_INSTALL_PATH} \
        -U\*_URL -U\*_TAG \
        -DUSE_SYSTEM_SWIG=On \
        -DUSE_SYSTEM_Boost=On \
        -DUSE_SYSTEM_Armadillo=On \
        -DUSE_SYSTEM_FFTW3=On \
        -DUSE_SYSTEM_HDF5=ON \
        -DBUILD_siemens_to_ismrmrd=On \
        -DUSE_ITK=ON \
        -DDEVEL_BUILD=OFF\
        -DNIFTYREG_USE_CUDA=OFF\
        -DBUILD_CIL=ON\
        -DPYTHON_EXECUTABLE="$PYTHON_EXECUTABLE"\
        -DBUILD_pet_rd_tools=ON
  cmake --build . -j${num_parallel}

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
