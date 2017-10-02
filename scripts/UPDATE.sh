#!/bin/bash
#
# Script to install/update the CCP-PETMR VM. It could also be used for any other system
# but will currently change your .sirfrc. This is to be avoided later on.
#
# Authors: Kris Thielemans and Evgueni Ovtchinnikov
# Copyright 2016-2017 University College London
# Copyright 2016-2017 Rutherford Appleton Laboratory STFC
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


# Exit if something goes wrong
set -e
# give a sensible error message (note: works only in bash)
trap 'echo An error occurred in $0 at line $LINENO. Current working-dir: $PWD' ERR

if [ -r ~/.sirfrc ]
then
  source ~/.sirfrc
else
  echo "I will create a ~/.sirfrc file and source this from your .bashrc"
  echo "source ~/.sirfrc" >> ~/.bashrc
fi

if [ -r ~/.sirf_VM_version ]
then
  source ~/.sirf_VM_version
else
  if [ -r /usr/local/bin/update_VM.sh ]
  then
    # we are on the old VM
    SIRF_VM_VERSION=0.1
    echo virtual | sudo -S apt-get -y install python-scipy python-docopt python-matplotlib
  else
    SIRF_VM_VERSION=0.9
  fi
  echo "export SIRF_VM_VERSION=$SIRF_VM_VERSION" > ~/.sirf_VM_version
fi

# location of sources
if [ -z $SIRF_SRC_PATH ]
then
  export SIRF_SRC_PATH=~/devel
  # overwriting .sirfrc but presumably it was empty anyway
  echo 'export SIRF_SRC_PATH=~/devel' > ~/.sirfrc
fi
if [ ! -d $SIRF_SRC_PATH ]
then
  mkdir -p $SIRF_SRC_PATH
fi


# SuperBuild
SuperBuild(){
  echo "==================== SuperBuild ====================="
  cd $SIRF_SRC_PATH
  # delete old VM build
  if [ ! -d SIRF-SuperBuild ] 
  then
    git clone https://github.com/CCPPETMR/SIRF-SuperBuild.git
    cd SIRF-SuperBuild
  else
    cd SIRF-SuperBuild
    git pull
  fi
  cd ..
  mkdir buildVM
  cd buildVM
  cmake ../SIRF-SuperBuild -DUSE_SYSTEM_SWIG=On -DUSE_SYSTEM_Boost=On -DUSE_SYSTEM_Armadillo=On -DUSE_SYSTEM_FFTW3=On
  make -j2
  cp INSTALL/bin/env_ccppetmr.sh ~/.sirfrc
  echo "export EDITOR=nano" >> ~/.sirfrc
  if [ ! -f INSTALL/share/gadgetron/config/gadgetron.xml ] 
  then 
    cp INSTALL/share/gadgetron/config/gadgetron.xml.example INSTALL/share/gadgetron/config/gadgetron.xml
  fi

  if [ $SIRF_VM_VERSION = "0.9" ] 
  then 
    echo "*********************************************************"
    echo "Your SIRF Installation is now Updated"
    echo "We reccommend to delete old files and directories:"
    echo ""
    echo "rm -rf $SIRF_SRC_PATH/build"
    echo "rm -rf $SIRF_SRC_PATH/gadgetron"
    echo "rm -rf $SIRF_SRC_PATH/ismrmrd-python-tools"
    echo "rm -rf $SIRF_SRC_PATH/ismrmrd"
    echo "rm -rf $SIRF_SRC_PATH/SIRF"
    echo "rm -rf $SIRF_SRC_PATH/STIR"
    echo "*********************************************************"
    echo "export SIRF_VM_VERSION=0.9.1" > ~/.sirf_VM_version
  fi
}

# define a function to get the source
# arguments: name_of_repo [git_ref]
clone_or_pull()
{
  repo=$1
  git_ref=${2:-master} # default to master
  echo "======================  Getting/updating source for $repo"
  cd $SIRF_SRC_PATH
  if [ -d $repo ]
  then
    cd $repo
    git fetch
  else
    git clone --recursive https://github.com/CCPPETMR/$repo
    cd $repo
  fi
  git checkout $git_ref
  git submodule update --init
}

# define a function to build and install
# arguments: name_of_repo [cmake arguments]
build_and_install()
{
  repo=$1
  shift
  echo "======================  Building $repo"
  cd $SIRF_BUILD_PATH
  if [ -d $repo ]
  then
    cd $repo
    cmake .
  else
    mkdir $repo
    cd $repo
    $CMAKE $* $SIRF_SRC_PATH/$repo
  fi
  echo "======================  Installing $repo"
  make install
}

# function to do everything
update()
{
  clone_or_pull $1
  build_and_install $*
}

# Launch the SuperBuild to update
SuperBuild

# copy scripts into the path
SIRF_INSTALL_PATH=$SIRF_SRC_PATH/buildVM/INSTALL
cp -vp $SIRF_SRC_PATH/CCPPETMR_VM/scripts/update*sh $SIRF_INSTALL_PATH/bin

# copy help file to Desktop
cp -vp $SIRF_SRC_PATH/CCPPETMR_VM/HELP.txt ~/Desktop

echo "SIRF update done!"
echo "Contents of your .sirfrc is now as follows"
cat ~/.sirfrc
echo "This file is sourced from your .bashrc."
echo "Close your terminal and re-open a new one to update your environment variables"
