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

# TODO would be better to guarantee absolute path for SCRIPTS
SCRIPTS="$(dirname $0)/../../docker"
# uninstall pexpect which is preinstalled in the VM
# https://github.com/SyneRBI/SIRF-SuperBuild/issues/742#issuecomment-1205090681
$SUDO apt remove -y python3-pexpect

$SUDO "$SCRIPTS/build_essential-ubuntu.sh"

APT_GET_INSTALL="$SUDO apt-get install -y --no-install-recommends"

echo "Installing linux headers for VGA updates"
# By appending the "true" we make sure that the script does not stop
# if this install failes (e.g. on Windows WSL2)
${APT_GET_INSTALL} linux-headers-$(uname -r) || true

$SUDO "$SCRIPTS/build_system-ubuntu.sh"

echo "Installing Gadgetron pre-requisites..."
$SUDO "$SCRIPTS/build_gadgetron-ubuntu.sh"
${APT_GET_INSTALL} libpugixml-dev

echo "Installing expect"
${APT_GET_INSTALL} expect

echo "Installing python APT packages"
# we will use pip for most
# some extra package needed for jupyter
# qt=pyqt5
# ${APT_GET_INSTALL} python3-dev python3-pip python3-tk python3-${qt} python3-${qt}.qtsvg python3-${qt}.qtwebkit

# echo "Installing CIL pre-requisites..."
# ${APT_GET_INSTALL} cython3 python3-h5py python3-wget
# dependency for ASTRA-toolbox autotools-dev automake autogen autoconf libtool

echo "Run INSTALL_python_packages.sh after this."
