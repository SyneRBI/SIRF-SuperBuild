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

echo "Installing python-dev APT package"
# we will use pip for everything else
${APT_GET_INSTALL} python3-dev

echo "Run INSTALL_python_packages.sh after this."
