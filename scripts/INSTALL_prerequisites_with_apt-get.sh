#! /bin/bash
# Script that install various packages needed for Gadgetron, SIRF etc
# on debian-based system (including Ubuntu).
#
# Needs to be run with super-user permissions, e.g. via sudo
#
# Please note: this script modifies your installation dramatically
# without asking any questions.
# We use it for the CCP PETMR VM etc.
# Use it with caution.


#if [ -z "SUDO" ]; then SUDO=sudo; fi

echo "Installing Gadgetron pre-requisites..."

$SUDO apt-get install -y --no-install-recommends libhdf5-serial-dev git-core cmake \
      build-essential libfftw3-dev h5utils \
      hdf5-tools hdfview liblapack-dev \
      libarmadillo-dev libace-dev  \
      libgtest-dev \
      libopenblas-dev libatlas-base-dev \
      libxml2-dev libxslt-dev \ # for siemens_to_ismrmrd
      cython
#      g++-6 gcc-6 
# Gadgetron dependencies, not required (yet) by SIRF
# only plplot install once https://github.com/gadgetron/gadgetron/issues/608 fixed
# in the Gadgetron version that we use
# libplplot-dev

echo "Installing boost 1.65 or later"
# first find current boost version (if any)
# the 'tail' makes sure we use the last one listed by apt-cache in case there is more than 1 version
tmp=`apt-cache search libboost|grep ALL|egrep libboost[1-9]|tail -n 1`
boost_major=${tmp:8:1}
boost_minor=${tmp:10:2}
echo "Found Boost major version ${boost_major}, minor ${boost_minor}"
if [ $boost_major -gt 1 -o $boost_minor -gt 64 ]
then
    $SUDO apt install -y libboost-dev
else    
    # packaged boost is too old
    # we need to find a ppa that has it. This is unsafe and likely prone to falling over
    # when the ppa is no longer maintained
    $SUDO apt install -y software-properties-common
    $SUDO add-apt-repository -y  ppa:mhier/libboost-latest
    $SUDO apt update
    # get rid of the default installed boost version
    $SUDO apt remove -y libboost-all-dev
    $SUDO apt auto-remove -y
    # TODO: find out which version is in the ppa
    $SUDO apt install -y libboost1.68-dev
fi

echo "Installing SWIG..."

$SUDO apt-get install -y --no-install-recommends swig

echo "Installing doxygen related packages"
$SUDO apt-get install -y --no-install-recommends doxygen graphviz

# replaced with pip install
#echo "Installing python libraries etc"
#$SUDO apt-get install -y --no-install-recommends  python-scipy python-docopt  python-numpy python-h5py python-matplotlib python-libxml2 python-psutil python-tk python-nose

echo "installing glog"
$SUDO apt-get install -y libgoogle-glog-dev

echo "Installing python APT packages"
# we will use pip for most
# some extra package needed for jupyter
qt=pyqt5
$SUDO apt-get install -y python-dev python-pip python-tk python-${qt} python-${qt}.qtsvg python-${qt}.qtwebkit
echo "Run INSTALL_python_packages.sh after this."
