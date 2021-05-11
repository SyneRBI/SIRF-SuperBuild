#!/bin/bash
# A script to update the VM to use "full CIL"
# - It will switch the CMake configuration to build CIL and ASTRA and
#   the CCPi Regularisation Toolkit and TomoPhantom.
#   
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
cmake -DBUILD_CIL:BOOL=ON .
make -j2 

# update/get CIL demos
cd $SIRF_SRC_PATH
if [ -d ./CIL-Demos ]; then
   cd ./CIL-Demos
   git pull
else
   git clone https://github.com/TomographicImaging/CIL-Demos.git 
   cd ./CIL-Demos
fi

python -m pip install --user nbstripout
nbstripout --install

echo "All done"
