#!/bin/bash
# A script to update the VM to use "full STIR"
# - It will switch the CMake configuration to build the STIR executables
#   and STIR python interface (which is separate from the SIRF Python
#   interface to STIR).
# - It will get the STIR-exercises from github
#
# Author: Kris Thielemans

echo "This script assumes you have run update_VM.sh already."
echo "Things will go horribly wrong otherwise."

source ~/.bashrc

# first do a very brief check
if [ -z "$INSTALL_DIR" -o ! -d ~/devel/build/install -o ! -d $BUILD_PATH/STIR ]; then
   echo "Directories not found. Run update_VM.sh"
   exit 1
fi

# change build files to also build the executables
cd $BUILD_PATH/STIR
$CMAKE -DBUILD_EXECUTABLES=ON -DBUILD_SWIG_PYTHON=ON $SRC_PATH/STIR
make -j2 install

# update/get STIR exercises
cd ~
if [ -d ~/STIR-exercises ]; then
   cd ~/STIR-exercises
   git pull
else
   git clone https://github.com/UCL/STIR-exercises.git
fi

echo "All done"
