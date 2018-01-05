#!/bin/bash
#
# Script to install/update VirtualBox Guest Additions on a Linux system.
#
# Authors: Kris Thielemans and Ben Thomas
# Copyright 2017 University College London
#
# This is software developed for the Collaborative Computational
# Project in Positron Emission Tomography and Magnetic Resonance imaging
# (http://www.ccppetmr.ac.uk/).

#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0.txt
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#=========================================================================


# Exit if something goes wrong
set -e
# give a sensible error message (note: works only in bash)
trap 'echo An error occurred in $0 at line $LINENO. Current working-dir: $PWD' ERR

if [ -r /media/*/VBOXADDITIONS*/VBoxLinuxAdditions.run ]; then
  VGArun=/media/*/VBOXADDITIONS*/VBoxLinuxAdditions.run
else
    echo "Failed to find VBox Guest Additions CD!" >> /dev/stderr
    echo "Please insert the CD and reboot the VM!" >> /dev/stderr
    echo "Aborting!" >> /dev/stderr
    exit
fi

# disable trapping if errors as we want to clean-up always
# even if the installer fails
set +e
trap "echo Something failed. Proceeding anyway." ERR
# execute the installer
sh $VGArun

# clean up
if [ -r /media/VGAiso/VBoxLinuxAdditions.run ]; then
  umount /media/VGAiso
  # don't delete the iso in case we need to re-run
  echo ""
  echo "You could delete /tmp/VBoxGuestAdditions_${vboxver}.iso"
fi

echo "Hopefully this all worked."
echo "Best to reboot the VM now."
