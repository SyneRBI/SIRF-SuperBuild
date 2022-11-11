#!/usr/bin/env bash
set -e
# SIRF external dependencies
apt-get update -qq
APT_GET_INSTALL="apt-get install -yq --no-install-recommends"

${APT_GET_INSTALL} software-properties-common # needed for add-apt-repository
add-apt-repository -y universe # needed for hdf5 for instance

# echo "Installing boost 1.71 or later (required for gadgetron)
# first find current boost version (if any)
function find_boost_version() {
  tmp=$(apt-cache search libboost|egrep 'libboost[1-9].*-dev'|tail -n 1)
  boost_major=${tmp:8:1}
  boost_minor=${tmp:10:2}
}

find_boost_version

# echo "Found Boost major version ${boost_major}, minor ${boost_minor}"
if [ "$boost_major" -gt 1 -o "$boost_minor" -gt 70 ]
then
    echo "installing Boost ${boost_major}.${boost_minor} from system apt"
    ${APT_GET_INSTALL} libboost-dev libboost-chrono-dev \
        libboost-filesystem-dev libboost-thread-dev \
        libboost-date-time-dev libboost-regex-dev \
        libboost-program-options-dev libboost-atomic-dev \
        libboost-test-dev libboost-timer-dev \
        libboost-coroutine-dev libboost-context-dev libboost-random-dev
else
    # packaged boost is too old
    # we need to find a ppa that has it. This is unsafe and likely prone to falling over
    # when the ppa is no longer maintained
    echo "Please submit a PR with a recent PPA for boost for your OS."
    exit 1
    # the mhier PPA is no longer supported
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
    ${APT_GET_INSTALL} "libboost${boost_major}.${boost_minor}-all-dev"
fi

${APT_GET_INSTALL} \
  libfftw3-dev         \
  libhdf5-serial-dev   \
  swig

# doxygen related packages
${APT_GET_INSTALL} doxygen graphviz

${APT_GET_INSTALL} libgoogle-glog-dev

# siemens_to_ismrmrd external dependencies
${APT_GET_INSTALL} \
  libxml2-dev          \
  libxslt-dev

# ASTRA toolbox external dependencies
${APT_GET_INSTALL} \
  autotools-dev        \
  automake             \
  autogen              \
  autoconf             \
  libtool

# ROOT external dependencies
${APT_GET_INSTALL} \
  uuid-dev

apt-get clean
