#! /bin/bash

#========================================================================
# Author: Kris Thielemans
# Copyright 2018 University College London
#
# This is software developed for the Collaborative Computational
# Project in Synergistic Reconstruction for Biomedical Imaging (formerly PETMR)
# (http://www.ccpsynerbi.ac.uk/).
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


location=`dirname $0`

# script to adjust gnome settings and other bits to be run only once 
# after VM is created

echo "Configuring GNOME"
"$location/configure_gnome.sh"

echo "configuring jupyter server"
"$location/configure_jupyter.sh"

echo "configuring matplotlib backend"
"$location/configure_matplotlib.sh"

echo "Done"
echo "Before exporting the VM, please run either $location/zero_fill.sh or $location/clean_before_VM_export.sh."

