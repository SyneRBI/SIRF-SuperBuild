#! /bin/sh

#========================================================================
# Author: Edoardo Pasca
# Copyright 2018 University College London
# Copyright 2018 Science Technology Facilities Council
#
# This file is part of the CCP PETMR Synergistic Image Reconstruction Framework (SIRF) virtual machine.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0.txt
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#=========================================================================

# script to adjust gnome settings and other bits to be run only once 
# after VM is created

PID=$(pgrep -u sirfuser gnome-session)
export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$PID/environ|cut -d= -f2-)
export DISPLAY=$(grep -z DISPLAY /proc/$PID/environ | cut -d= -f2-)
#echo "display " $DISPLAY " dbus " $DBUS_SESSION_BUS_ADDRESS

# add input sources
sudo gsettings set org.gnome.desktop.input-sources sources "[('xkb','uk'), ('xkb','us'),('xkb','de'),('xkb','fr'),('xkb','es'),('xkb','it'),('xkb','pt'),('xkb','br'),('xkb','jp'),('xkb','cn')]"
# remove screen lock for sirfuser
sudo gsettings set org.gnome.desktop.lockdown disable-lock-screen 'true'

#zerofill
sudo dd if=/dev/zero of=/EMPTY bs=1M
sudo rm -f /EMPTY
dd 
