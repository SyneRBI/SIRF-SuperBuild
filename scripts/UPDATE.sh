#!/bin/bash
#
# Script to install/update the SyneRBI VM. It could also be used for any
# other system but will currently change your .sirfrc.
# This is to be avoided later on.
#
# Authors: Kris Thielemans, Evgueni Ovtchinnikov, Edoardo Pasca,
# Casper da Costa-Luis
# Copyright 2016-2020 University College London
# Copyright 2016-2020 Rutherford Appleton Laboratory STFC
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
SB_TAG='default'
num_parallel=2
update_remote=0
apt_install=0
while getopts hrst:j: option
 do
 case "${option}"
 in
  r) update_remote=1;;
  s) apt_install=1;;
  t) SB_TAG=$OPTARG;;
  j) num_parallel=$OPTARG;;
  h)
   echo "Usage: $0 [-t tag] [-j n] [-r] [-s]"
   echo "Use the tag option to checkout a specific version of the SIRF-SuperBuild."
   echo "   Otherwise the most recent release will be used."
   echo "Use the -j option to change the number of parallel builds from the default ${num_parallel}"
   echo "Use the -r option to reset your git remotes to default SyneRBI sources."
   echo "  We recommend to do this once when upgrading a CCPPETMR_VM."
   echo "Use the -s option to update and install necessary system and Python components (use with caution)."
   exit 
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

if [ -r ~/.sirfrc ]
then
  source ~/.sirfrc
else
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

# check current version (if any) to take into account later on
# (the new VM version will be saved at the end of the script)
if [ -r ~/.sirf_VM_version ]
then
  source ~/.sirf_VM_version
else
  if [ -r /usr/local/bin/update_VM.sh ]
  then
    # we are on the very first VM
    SIRF_VM_VERSION=0.1
    echo virtual | sudo -S apt-get -y install python-scipy python-docopt python-matplotlib
    echo '======================================================'
    echo 'You have a very old VM. This update is likely to fail.'
    echo '======================================================'
  else
    if [ -r ~/.sirfrc ]; then
      SIRF_VM_VERSION=0.9
      echo '======================================================'
      echo 'You have a very old VM.'
      echo 'You will probably have to update system files and re-run the update.'
      echo 'Check the INSTALL_* files.'
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
if [ ! -d $SIRF_SRC_PATH ]
then
  mkdir -p $SIRF_SRC_PATH
fi

# cope with CCP-PETMR renaming
if [ -d $SIRF_SRC_PATH/CCPPETMR_VM ]; then
  if [ ! -h $SIRF_SRC_PATH/SyneRBI_VM ]; then
    ln -s $SIRF_SRC_PATH/CCPPETMR_VM $SIRF_SRC_PATH/SyneRBI_VM
    if [ $update_remote == 1 ]; then
        cd $SIRF_SRC_PATH/CCPPETMR_VM
        git remote set-url origin https://github.com/SyneRBI/SyneRBI_VM.git
    fi
  fi
fi

SIRF_INSTALL_PATH=$SIRF_SRC_PATH/install

# ignore notebook keys, https://github.com/CCPPETMR/SIRF-Exercises/issues/20
python -m pip install -U --user nbstripout==0.3.7
git config --global filter.nbstripout.extrakeys '
  metadata.celltoolbar metadata.language_info.codemirror_mode.version
  metadata.language_info.pygments_lexer metadata.language_info.version'

# Optionally install pre-requisites
if [ $apt_install == 1 ]; then
  cd ~/devel/SyneRBI_VM/scripts
  sudo -H ./INSTALL_prerequisites_with_apt-get.sh
  sudo -H ./INSTALL_python_packages.sh
  sudo -H ./INSTALL_CMake.sh
  ./configure_gnome.sh
fi

# SuperBuild
SuperBuild(){
  echo "==================== SuperBuild ====================="
  cd $SIRF_SRC_PATH
  if [ ! -d SIRF-SuperBuild ] 
  then
    git clone https://github.com/SyneRBI/SIRF-SuperBuild.git
    cd SIRF-SuperBuild
  else
    cd SIRF-SuperBuild
    if [ $update_remote == 1 ]; then
        git remote set-url origin https://github.com/SyneRBI/SIRF-SuperBuild.git
    fi
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
  git checkout $SB_TAG
  cd ..
  mkdir -p buildVM
  
  cd buildVM
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
        -DBUILD_CIL_LITE=ON\
        -DNIFTYREG_USE_CUDA=OFF\
	-DBUILD_pet_rd_tools=ON
  make -j${num_parallel}

  if [ ! -f ${SIRF_INSTALL_PATH}/share/gadgetron/config/gadgetron.xml ]
  then
      if [ -f ${SIRF_INSTALL_PATH}/share/gadgetron/config/gadgetron.xml.example ]
      then
          cp ${SIRF_INSTALL_PATH}/share/gadgetron/config/gadgetron.xml.example ${SIRF_INSTALL_PATH}/share/gadgetron/config/gadgetron.xml
      fi
  fi

  if [ $SIRF_VM_VERSION = "0.9" ] 
  then 
    echo "*********************************************************"
    echo "We recommend to delete old files and directories:"
    echo ""
    echo "rm -rf $SIRF_SRC_PATH/build"
    echo "rm -rf $SIRF_SRC_PATH/gadgetron"
    echo "rm -rf $SIRF_SRC_PATH/ismrmrd"
    echo "rm -rf $SIRF_SRC_PATH/SIRF"
    echo "rm -rf $SIRF_SRC_PATH/STIR"
    echo "*********************************************************"
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
    git fetch --tags
    git pull
  else
    git clone --recursive $repoURL
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

# Launch the SuperBuild to update
SuperBuild $SB_TAG

# copy scripts into the path
cp -vp $SIRF_SRC_PATH/SyneRBI_VM/scripts/update*sh $SIRF_INSTALL_PATH/bin

# Get extra python tools
clone_or_pull  https://github.com/SyneRBI/ismrmrd-python-tools.git
cd $SIRF_SRC_PATH/ismrmrd-python-tools
python setup.py install --user

# install the SIRF-Exercises
cd $SIRF_SRC_PATH
clone_or_pull  https://github.com/SyneRBI/SIRF-Exercises.git
cd $SIRF_SRC_PATH/SIRF-Exercises
PY_USER_BIN=`python -c 'import site; import os; print ( os.path.join(site.USER_BASE , "bin") )'`
export PATH=${PY_USER_BIN}:${PATH}
nbstripout --install

# check STIR-exercises
cd $SIRF_SRC_PATH
if [ -d STIR-exercises ]; then
  cd STIR-exercises
  git pull
fi

# copy help file to Desktop
if [ ! -d ~/Desktop ]
then
  if [ -e ~/Desktop ]
    then 
	mv ~/Desktop ~/Desktop.file
  fi
  mkdir ~/Desktop 
fi 
cp -vp $SIRF_SRC_PATH/SyneRBI_VM/HELP.txt ~/Desktop/

if [ -r ~/.sirfc ]; then
  echo "Moving existing ~/.sirfc to a backup copy"
  mv -v ~/.sirfc ~/.sirfc.old
fi
echo "export SIRF_SRC_PATH=$SIRF_SRC_PATH" > ~/.sirfrc
echo "source ${SIRF_INSTALL_PATH}/bin/env_ccppetmr.sh" >> ~/.sirfrc
echo "export EDITOR=nano" >> ~/.sirfrc
if [ ! -z "$STIR_exercises_PATH" ]; then
    echo "export STIR_exercises_PATH=$SIRF_SRC_PATH/STIR-exercises" >> ~/.sirfrc
fi

version=`echo -n "export SIRF_VM_VERSION=" | cat - ${SIRF_SRC_PATH}/SyneRBI_VM/VM_version.txt`
echo $version > ~/.sirf_VM_version

echo ""
echo "SIRF update done!"
echo "Contents of your .sirfrc is now as follows"
echo "=================================================="
cat ~/.sirfrc
echo "=================================================="
echo "This file is sourced from your .bashrc."
echo "Close your terminal and re-open a new one to update your environment variables"
