#!/bin/bash
#
# Script to install/update VirtualBox Guest Additions on a Linux system.
#
# Authors: Kris Thielemans and Ben Thomas
# Copyright 2017-2018 University College London
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
    # get the VB version using a trick from Ben Thomas
    #vboxver=`dmidecode | grep vboxVer | sed 's/.*_//'`
    #cd /tmp
    # get the iso if it doesn't exist yet
    #if [ -r  VBoxGuestAdditions_${vboxver}.iso ]; then
    #  echo "Using existing file /tmp/VBoxGuestAdditions_${vboxver}.iso"
    #else
    #  wget http://download.virtualbox.org/virtualbox/${vboxver}/VBoxGuestAdditions_${vboxver}.iso
    #fi
    #mkdir -p /media/VGAiso
    #mount -o loop VBoxGuestAdditions_${vboxver}.iso /media/VGAiso
    #VGArun=/media/VGAiso/VBoxLinuxAdditions.run

    echo "Failed to find VBox Guest Additions CD!" >> /dev/stderr
    read -n1 -r -p "Please insert the CD using the VirtualBox menu and press any key to continue..." key

    if [ -r /media/*/VBOXADDITIONS*/VBoxLinuxAdditions.run ]; then
      VGArun=/media/*/VBOXADDITIONS*/VBoxLinuxAdditions.run
    else
        echo "CD still not found. Trying /dev/sr0 !" >> /dev/stderr
        mkdir -p /media/cdrom

        ARGS="mount -t iso9660 /dev/sr0 /media/cdrom"

        if eval $ARGS ; then
          if [ -r /media/cdrom/VBoxLinuxAdditions.run ]; then
            VGArun=/media/cdrom/VBoxLinuxAdditions.run
          else
            echo "Could not find VGA on /media/cdrom either!" >> /dev/stderr
          fi
        else
          echo "Could not mount to /media/cdrom either!" >> /dev/stderr
        fi
    fi
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
  #echo "You could delete /tmp/VBoxGuestAdditions_${vboxver}.iso"
fi

# clean up
if [ -r /media/cdrom/VBoxLinuxAdditions.run ]; then
  umount /media/cdrom
  # don't delete the iso in case we need to re-run
  echo ""
  #echo "You could delete /tmp/VBoxGuestAdditions_${vboxver}.iso"
fi

echo "Hopefully this all worked."
echo "Best to reboot the VM now."
