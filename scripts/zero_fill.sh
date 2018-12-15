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

# script  allow a VM export to be compact

echo "Now creating a very large file filled with zeroes, and then delete it"
echo "such that VirtualBox will create a compact OVA file."
echo "You will see message saying \"error writing '/tmp/EMPTY'\". This is expected."
dd if=/dev/zero of=/tmp/EMPTY bs=1M
rm -f /tmp/EMPTY
 
