#! /bin/bash

#========================================================================
# Author: Kris Thielemans
# Copyright 2018 University College London
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

location=`dirname $0`

$location/configure_gnome.sh

# configure jupyter notebook
mkdir ~/.jupyter
jupyter notebook --generate-config
# requires to set the following variable manually by editing the file
# jupyter_notebook_config.py
# c.NotebookApp.ip = '0.0.0.0'
jupyter notebook password

$location/zero_fill.sh

