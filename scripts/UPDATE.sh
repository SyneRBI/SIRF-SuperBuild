#!/bin/bash
#
# Script to install/update the CCP-PETMR VM. It could also be used for any other system
# but will currently change your .bashrc. This is to be avoided later on.
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

PASSWD=virtual

echo $PASSWD | sudo -S apt-get -y install python-scipy python-docopt python-matplotlib

source ~/.bashrc

if [ -z $SRC_PATH ]
then
  export SRC_PATH=~/devel
  echo 'export SRC_PATH=~/devel' > ~/.bashrc
fi
if [ ! -d $SRC_PATH ]
then
  # create it in a very dangerous fashion
  # This is hopefully ok as we know what the history was of the VM.
  # We will need to fix this when we create a new VM.
  mkdir -p $SRC_PATH
fi

if [ -z $INSTALL_DIR ]
then
  export INSTALL_DIR=~/devel/build/install
  echo 'export INSTALL_DIR=~/devel/build/install' >> ~/.bashrc
  export LD_LIBRARY_PATH=$INSTALL_DIR/lib:$LD_LIBRARY_PATH
  echo 'export LD_LIBRARY_PATH=$INSTALL_DIR/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
  export PYTHONPATH=$INSTALL_DIR/python
  echo 'export PYTHONPATH=$INSTALL_DIR/python' >> ~/.bashrc
  export CMAKE="cmake -DCMAKE_PREFIX_PATH:PATH=$INSTALL_DIR/lib/cmake -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_DIR"
  echo 'export CMAKE="cmake -DCMAKE_PREFIX_PATH:PATH=$INSTALL_DIR/lib/cmake -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_DIR"' >> ~/.bashrc
  export CCMAKE="ccmake -DCMAKE_PREFIX_PATH:PATH=$INSTALL_DIR/lib/cmake -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_DIR"
  echo 'export CCMAKE="ccmake -DCMAKE_PREFIX_PATH:PATH=$INSTALL_DIR/lib/cmake -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_DIR"' >> ~/.bashrc
fi

if [ ! -d $INSTALL_DIR ]
then
  # create it in a very dangerous fashion
  # This is hopefully ok as we know what the history was of the VM.
  # We will need to fix this when we create a new VM.
  mkdir -p ~/devel/build
  cd ~/devel/build
  echo $PASSWD | sudo -S rm -r -f *
  mkdir install
  mkdir install/bin
fi

# define a function to get the source
# argument: name of repo
clone_or_pull()
{
  repo=$1
  cd $SRC_PATH
  if [ -d $repo ]
  then
    cd $repo
    git pull
    git submodule update --init
  else
    git clone --recursive https://github.com/CCPPETMR/$repo
  fi
}

# define a function to bulid and install
# arguments: name_of_repo [cmake arguments]
build_and_install()
{
  repo=$1
  shift
  cd $BUILD_PATH
  if [ -d $repo ]
  then
    cd $repo
    cmake .
  else
    mkdir $repo
    cd $repo
    $CMAKE $* $SRC_PATH/$repo
  fi
  make install
}

# function to do everything
update()
{
  clone_or_pull $1
  build_and_install $*
}

update ismrmrd
update STIR  -DGRAPHICS=None -DBUILD_EXECUTABLES=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON
update gadgetron
update SIRF

clone_or_pull ismrmrd-python-tools
cd $SRC_PATH/ismrmrd-python-tools
# TODO avoid sudo here
echo $PASSWD | sudo -S  python setup.py install


# update STIR-exercises if it was installed
# See update_VM_to_full_STIR.sh
if [ -d ~/STIR-exercises ]
then
    cd ~/STIR-exercises
    git pull
fi


# copy scripts into the path
cp -vp $SRC_PATH/CCPPETMR_VM/scripts/update*sh $INSTALL_DIR/bin
# check if the directory is in the path
if type update_VM_to_full_STIR.sh >/dev/null 2>&1
then
  : # ok
else
    echo "PATH=\$PATH:$INSTALL_DIR/bin" >> ~/.bashrc
    echo "Close your terminal and re-open a new one to update your environment variables, or type"
    echo ". ~/.bashrc"
fi
