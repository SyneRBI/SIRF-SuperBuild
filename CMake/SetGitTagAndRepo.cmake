#========================================================================
# Author: Richard Brown
# Copyright 2019, 2020 University College London
#
# This file is part of the CCP SyneRBI (formerly PETMR) Synergistic Image Reconstruction Framework (SIRF) SuperBuild.
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

# This file defines a macro that sets a variable `${proj}_EP_ARGS_GIT`,
# which can then be used in the `External_project_add` call.
# Normally the variable contains settings for `GIT_REPOSITORY` and `GIT_TAG`,
# setting them to `${proj}_URL` and `${proj}_TAG` respectively.
#
# If the user doesn't want git checkout to be performed,
# she should set `DISABLE_GIT_CHECKOUT_STIR_${proj}=ON`, which
# will set `${proj}_EP_ARGS_GIT` to a blank string.
#
# Example usage:
#   cmake . -DDISABLE_GIT_CHECKOUT_STIR:BOOL=ON
#

macro(SetGitTagAndRepo proj)
	
	# Add the option to ignore
	option(DISABLE_GIT_CHECKOUT_${proj} "Disable git checkout of ${proj}. Ignored if source directory does not exist (e.g., on first run)." OFF)
	mark_as_advanced(DISABLE_GIT_CHECKOUT_${proj})
	
	# If disable git desired (and source directory exists), set tag and repo to blank
	if (EXISTS "${${proj}_SOURCE_DIR}" AND DISABLE_GIT_CHECKOUT_${proj})
		message(STATUS "Not going to perform git checkout for ${proj}...")
		set(${proj}_EP_ARGS_GIT "")
	# Else, 
	else()
		message(STATUS "Will perform git checkout for ${proj}...")
		set(${proj}_EP_ARGS_GIT
                    GIT_REPOSITORY ${${proj}_URL}
                    GIT_TAG ${${proj}_TAG}
                 )
	endif()
endmacro()
