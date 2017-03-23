#! /bin/bash

if [ -z "SUDO" ]; then SUDO=sudo; fi

echo "Installing SWIG..."

$SUDO apt-get install swig

echo "Installing python libraries"
$SUDO apt-get install python-scipy python-docopt 

echo "Installing Gadgetron pre-requisites..."

$SUDO apt-get install libhdf5-serial-dev cmake git-core \
libboost-all-dev build-essential libfftw3-dev h5utils \
hdf5-tools hdfview python-dev python-numpy liblapack-dev libxml2-dev \
libxslt-dev libarmadillo-dev libace-dev python-h5py \
python-matplotlib python-libxml2 gcc-multilib python-psutil \
libgtest-dev libplplot-dev
