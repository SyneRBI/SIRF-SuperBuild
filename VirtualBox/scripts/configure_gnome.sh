#! /bin/bash

#========================================================================
# Author: Edoardo Pasca
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

# add input sources
gsettings set org.gnome.desktop.input-sources sources "[('xkb','gb'), ('xkb','us'),('xkb','de'),('xkb','fr'),('xkb','es'),('xkb','it'),('xkb','pt'),('xkb','br'),('xkb','jp'),('xkb','cn')]"
# remove screen lock for sirfuser
gsettings set org.gnome.desktop.lockdown disable-lock-screen 'true'
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
# enlarge pointer size
gsettings set org.gnome.desktop.interface cursor-size 120
# remove autosuspend notification
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout '0'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout '0'

