#!/bin/bash
#
# Script to install/update the SyneRBI VM.
# Check the process_options function in UPDATE_functions.sh for usage.
#
# This script essentially just calls UPDATE.sh. The reason for this split
# is somewhat tricky. UPDATE.sh lives in the source of the SIRF-SuperBuild.
# It will set the SIRF-SuperBuild to a desired version. However, by doing that,
# it will potentially check-out a new version of itself. This will make
# a running script crash.
# We solve this using the following strategy:
# 1. let update_VM.sh update the source tree, and then exec UPDATE.sh in the source tree
# 2. copy update_VM.sh to the install location (i.e. outside the source tree).
# 3. When typing "update_VM.sh", a user will call the installed version, which will
#    be replaced by a new version by UPDATE.sh
# This way, no running script modifies itself.


# Authors: Kris Thielemans
# Copyright 2016-2022 University College London
#
# This is software developed for the Collaborative Computational
# Project in Synergistic Reconstruction for Biomedical Imaging (formerly PETMR)
# (http://www.ccpsynerbi.ac.uk/).

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

if [ -z "$SIRF_SRC_PATH" ]; then
  SIRF_SRC_PATH=~/devel
fi

script_loc="$SIRF_SRC_PATH"/SIRF-SuperBuild/VirtualBox/scripts
source "${script_loc}/UPDATE_functions.sh"

# process command line options
process_options "$0" $*
initialise_environment
echo "Updating SIRF-SuperBuild..."
# This will put the SIRF-SuperBuild at the desired version
SuperBuild_git_update "$SB_TAG"
# Now call UPDATE.sh of the desired version
# (That script will checkout the SIRF-SuperBuild version again, but
# that won't change UPDATE.sh, so this should be safe)
exec "$script_loc"/UPDATE.sh $*
