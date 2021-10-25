#!/bin/bash
# A script to update the VM to use "full CIL"
# - It will switch the CMake configuration to build CIL and ASTRA and
#   the CCPi Regularisation Toolkit and TomoPhantom.
#   
#
# Author: Kris Thielemans, Edoardo Pasca

echo "This script assumes you have run update_VM.sh already."
echo "Things will go horribly wrong otherwise."

# first do a very brief check
if [ -z "$SIRF_PATH" -o ! -d $SIRF_PATH -o ! -d $SIRF_PATH/../STIR ]; then
   echo "Directories not found. Run update_VM.sh"
   exit 1
fi

APT_GET_INSTALL="sudo apt-get install -y --no-install-recommends"
# install CIL prerequisites
${APT_GET_INSTALL} cython3 python3-h5py python3-wget
# install ASTRA prerequisites
${APT_GET_INSTALL} autotools-dev automake autogen autoconf libtool
# change build files to also build the CIL and ASTRA executables
cd $SIRF_PATH/../..
cmake -DBUILD_CIL:BOOL=ON .
cmake --build . -j2 

# update/get CIL demos
cd $SIRF_SRC_PATH
if [ -d ./CIL-Demos ]; then
   cd ./CIL-Demos
   git pull
else
   git clone https://github.com/TomographicImaging/CIL-Demos.git 
   cd ./CIL-Demos
fi

#make sure nbstripout is installed and apply filter to CIL-Demos repo
python3 -m pip install --user nbstripout
nbstripout --install

echo "All done"
