#! /bin/bash
# Script that install various packages needed for Gadgetron, SIRF etc
# on debian-based system (including Ubuntu).
#
# Please note: this script modifies your installation dramatically
# without asking any questions.
# We use it for the CCP PETMR VM etc.
# Use it with caution.
set -e

#if [ -z "SUDO" ]; then SUDO=sudo; fi
export DEBIAN_FRONTEND=noninteractive
SUDO=sudo

APT_GET_INSTALL="$SUDO apt-get install -y --no-install-recommends"

${APT_GET_INSTALL} build-essential
echo "Installing linux headers for VGA updates"
# By appending the "true" we make sure that the script does not stop
# if this install failes (e.g. on Windows WSL2)
${APT_GET_INSTALL} linux-headers-$(uname -r) || true

echo "Installing Gadgetron pre-requisites..."
${APT_GET_INSTALL} libhdf5-serial-dev git libfftw3-dev h5utils hdf5-tools \
	liblapack-dev liblapacke-dev libarmadillo-dev libace-dev libgtest-dev libopenblas-dev libpugixml-dev \
	libatlas-base-dev libatlas-base-dev libxml2-dev libxslt1-dev unzip \
	libdcmtk-dev

# install libgmock-dev if in the apt packages https://github.com/SyneRBI/SIRF-SuperBuild/issues/647#issuecomment-1042841986

if apt-cache show libgmock-dev >& /dev/null; then
  apt install  libgmock-dev
fi

echo "Installing boost 1.65 or later"
# first find current boost version (if any)
# the 'tail' makes sure we use the last one listed by apt-cache in case there is more than 1 version
function find_boost_version() {
  tmp=`apt-cache search libboost|grep ALL|egrep libboost[1-9]|tail -n 1`
  boost_major=${tmp:8:1}
  boost_minor=${tmp:10:2}
}

find_boost_version

echo "Found Boost major version ${boost_major}, minor ${boost_minor}"
if [ $boost_major -gt 1 -o $boost_minor -gt 64 ]
then
    echo "installing Boost ${boost_major}.${boost_minor} from system apt"
    ${APT_GET_INSTALL} libboost-dev libboost-chrono-dev \
        libboost-filesystem-dev libboost-thread-dev \
        libboost-date-time-dev libboost-regex-dev \
        libboost-program-options-dev libboost-atomic-dev \
        libboost-test-dev libboost-timer-dev
else    
    # packaged boost is too old
    # we need to find a ppa that has it. This is unsafe and likely prone to falling over
    # when the ppa is no longer maintained
    echo "trying to find boost from ppa:mhier/libboost-latest"
    ${APT_GET_INSTALL} software-properties-common
    $SUDO add-apt-repository -y  ppa:mhier/libboost-latest
    $SUDO apt update
    # get rid of the default installed boost version
    $SUDO apt remove -y libboost-all-dev
    $SUDO apt auto-remove -y
    # TODO: find out which version is in the ppa
    find_boost_version
    echo "installing Boost ${boost_major}.${boost_minor} from ppa:mhier apt"
    ${APT_GET_INSTALL} libboost${boost_major}.${boost_minor}-all-dev
fi

echo "Installing SWIG..."

${APT_GET_INSTALL} swig

echo "Installing doxygen related packages"
${APT_GET_INSTALL} doxygen graphviz

# replaced with pip install
#echo "Installing python libraries etc"
#$SUDO apt-get install -y --no-install-recommends  python-scipy python-docopt  python-numpy python-h5py python-matplotlib python-libxml2 python-psutil python-tk python-nose

echo "Installing glog"
${APT_GET_INSTALL} libgoogle-glog-dev

echo "Installing unzip"
${APT_GET_INSTALL} unzip

echo "Installing expect"
${APT_GET_INSTALL} expect

echo "Installing python APT packages"
# we will use pip for most
# some extra package needed for jupyter
qt=pyqt5
${APT_GET_INSTALL} python3-dev python3-pip python3-tk python3-${qt} python3-${qt}.qtsvg python3-${qt}.qtwebkit

echo "Installing CIL pre-requisites..."
${APT_GET_INSTALL} cython3 python3-h5py python3-wget
# dependency for ASTRA-toolbox autotools-dev automake autogen autoconf libtool

echo "Run INSTALL_python_packages.sh after this."
