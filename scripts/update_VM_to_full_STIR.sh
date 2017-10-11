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

# first do a very brief check
if [ -z "$SIRF_PATH" -o ! -d $SIRF_PATH -o ! -d $SIRF_PATH/../STIR ]; then
   echo "Directories not found. Run update_VM.sh"
   exit 1
fi

# change build files to also build the STIR executables
cd $SIRF_PATH/..
cmake -DBUILD_STIR_EXECUTABLES=ON -DBUILD_STIR_SWIG_PYTHON=ON .
make -j2 

# update/get STIR exercises
cd $SIRF_SRC_PATH
if [ -d ./STIR-exercises ]; then
   cd ./STIR-exercises
   git pull
else
   git clone https://github.com/UCL/STIR-exercises.git
fi

echo "All done"
