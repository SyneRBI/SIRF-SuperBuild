#========================================================================
# Author: Ander Biguri
# Copyright 2020 University College London
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

# This defines a macro that gets flags passed to the superbuild to modify particular project cmake flags and marks them as advanced.
# Allows passing cmake flags to the superbuild to be reused by particular projects.

macro(SetExternalProjectFlags proj)

	set(${proj}_EXTRA_CMAKE_ARGS "" CACHE STRING "Optional extra CMake arguments to be appended to the flags set by the SuperBuild(use semi-colons for multiple arguments)")
	mark_as_advanced(${proj}_EXTRA_CMAKE_ARGS)
	# string(REPLACE " " ";" ${proj}_EXTRA_CMAKE_ARGS_LIST "${${proj}_EXTRA_CMAKE_ARGS}")
	message(STATUS ${proj}_EXTRA_CMAKE_ARGS= "${${proj}_EXTRA_CMAKE_ARGS}")
endmacro()
