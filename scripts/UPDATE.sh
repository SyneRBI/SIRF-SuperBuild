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
    SIRF_VM_VERSION=0.9.1
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



# location of installated files
#if [ -z $SIRF_INSTALL_PATH ]
#then
#  export SIRF_BUILD_PATH=$SIRF_SRC_PATH/build
#  echo "export SIRF_BUILD_PATH=$SIRF_BUILD_PATH" >> ~/.sirfrc
#  export SIRF_INSTALL_PATH=$SIRF_SRC_PATH/build/install
#  echo "export SIRF_INSTALL_PATH=$SIRF_INSTALL_PATH" >> ~/.sirfrc
#  export SIRF_PATH=$SIRF_SRC_PATH/SIRF
#  echo "export SIRF_PATH=$SIRF_PATH" >> ~/.sirfrc
#  export LD_LIBRARY_PATH=$SIRF_INSTALL_PATH/lib:$LD_LIBRARY_PATH
#  echo 'export LD_LIBRARY_PATH=$SIRF_INSTALL_PATH/lib:$LD_LIBRARY_PATH' >> ~/.sirfrc
#  export PYTHONPATH=$SIRF_INSTALL_PATH/python
#  echo 'export PYTHONPATH=$SIRF_INSTALL_PATH/python' >> ~/.sirfrc
#  echo "PATH=\$PATH:$SIRF_INSTALL_PATH/bin" >> ~/.sirfrc
#fi
#
#CMAKE="cmake -DCMAKE_PREFIX_PATH:PATH=$SIRF_INSTALL_PATH/lib/cmake -DCMAKE_INSTALL_PREFIX:PATH=$SIRF_INSTALL_PATH"
#
#if [ ! -d $SIRF_INSTALL_PATH ]
#then
#  mkdir -p $SIRF_INSTALL_PATH/bin
#fi
#


# SuperBuild
SuperBuild(){
  echo "==================== SuperBuild ====================="
  cd $SIRF_SRC_PATH
  git clone https://github.com/CCPPETMR/SIRF-SuperBuild.git
  cd SIRF-SuperBuild
  git checkout ctest
  cmake . -DSIRF_TAG=40e3264963ba7448bffb1dcbc9b55ef00ace6f8c
  make
  cp INSTALL/bin/env_ccppetmr.sh ~/.sirfrc
  if [ ! -f INSTALL/share/gadgetron/config/gadgetron.xml ] 
  then 
    cp INSTALL/share/gadgetron/config/gadgetron.xml.example INSTALL/share/gadgetron/config/gadgetron.xml
  fi
  source ~/.sirfrc
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

SuperBuild

#clone_or_pull ismrmrd f98df72fcd85e739fb41083561d8d96c951520bd
#build_and_install ismrmrd
#
#update STIR  -DGRAPHICS=None -DBUILD_EXECUTABLES=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON
#update gadgetron
#update SIRF
#
## check if gadgetron config file exists
#gadgetron_config=$SIRF_INSTALL_PATH/share/gadgetron/config/gadgetron.xml
#if [ ! -r  ${gadgetron_config} ]; then
#  cp ${gadgetron_config}.example ${gadgetron_config}
#fi
#
#clone_or_pull ismrmrd-python-tools
#cd $SIRF_SRC_PATH/ismrmrd-python-tools
#python setup.py install --user
#
#
## update STIR-exercises if it was installed
## See update_VM_to_full_STIR.sh
#if [ -d $SIRF_SRC_PATH/STIR-exercises ]
#then
#    cd $SIRF_SRC_PATH/STIR-exercises
#    git pull
#fi
#
#
# copy scripts into the path
cp -vp $SIRF_SRC_PATH/CCPPETMR_VM/scripts/update*sh $SIRF_INSTALL_PATH/bin

# copy help file to Desktop
cp -vp $SIRF_SRC_PATH/CCPPETMR_VM/HELP.txt ~/Desktop

echo "SIRF update done!"
echo "Contents of your .sirfrc is now as follows"
cat ~/.sirfrc
echo "This file is sourced from your .bashrc."
echo "Close your terminal and re-open a new one to update your environment variables"
