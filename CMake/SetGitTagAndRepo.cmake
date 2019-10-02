#========================================================================
# Author: Richard Brown
# Copyright 2019 University College London
#
# This file is part of the CCP PETMR Synergistic Image Reconstruction Framework (SIRF) SuperBuild.
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

# This file defines a macro that sets ${proj}_URL_MODIFIED and ${proj}_TAG_MODIFIED.
# If the user doesn't want git checkout to be performed, 
# these will be set to blank strings. Else, they'll be set to 
# ${${proj}_URL} and ${${proj}_TAG}, respectively.
#
# Example usage:
#   cmake . -DDISABLE_GIT_CHECKOUT_STIR=ON
#
# This will call SetGitTagAndRepo(STIR), setting 
# STIR_TAG_MODIFIED and STIR_URL_MODIFIED accordingly.

macro(SetGitTagAndRepo proj)
	
	# Add the option to ignore
	option(DISABLE_GIT_CHECKOUT_${proj} "Disable git checkout of ${proj}. Ignored if source directory does not exist (e.g., on first run)." OFF)
	mark_as_advanced(DISABLE_GIT_CHECKOUT_${proj})
	
	# If disable git desired (and source directory exists), set tag and repo to blank
	if (EXISTS "${${proj}_SOURCE_DIR}" AND DISABLE_GIT_CHECKOUT_${proj})
		message(STATUS "Not going to perform git checkout for ${proj}...")
		SET(${proj}_TAG_MODIFIED "")
		SET(${proj}_URL_MODIFIED "")
	# Else, 
	else()
		message(STATUS "Will perform git checkout for ${proj}...")
		SET(${proj}_TAG_MODIFIED "${${proj}_TAG}")
		SET(${proj}_URL_MODIFIED "${${proj}_URL}")
	endif()
endmacro()