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
cd $SIRF_PATH/../..
cmake -DSTIR_BUILD_EXECUTABLES=ON -DSTIR_BUILD_SWIG_PYTHON=ON .
make -j2 

# update/get STIR exercises
cd $SIRF_SRC_PATH
if [ -d ./STIR-exercises ]; then
   cd ./STIR-exercises
   git pull
else
   git clone https://github.com/UCL/STIR-exercises.git 
   cd ./STIR-exercises
fi

python -m pip install --user nbstripout
nbstripout --install

# create shortcut on Desktop
if [ ! -r ~/Desktop/STIR-exercises-README.md ]; then
    cd ~/Desktop
    ln -s $SIRF_SRC_PATH/STIR-exercises/README.md STIR-exercises-README.md
fi

# Check if csh is present
# commented out as no longer necessary
# command -v csh >/dev/null 2>&1 || { echo >&2 "We need csh. Please type 'sudo apt-get install tcsh'"; }
                                    
if [ -z "$STIR_exercises_PATH" ]; then
    echo "export STIR_exercises_PATH=$SIRF_SRC_PATH/STIR-exercises" >> ~/.sirfrc
    echo "Your ~/.sirfrc has been updated."
    echo "Close your terminal and re-open a new one to update your environment variables"
fi

echo "All done"
