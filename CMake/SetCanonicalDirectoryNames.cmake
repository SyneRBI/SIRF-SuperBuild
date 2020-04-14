#========================================================================
# Author: Kris Thielemans
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

# This file defines a macro that sets ${proj}_*_DIR and ${proj}_EP_ARGS_DIR to canonical locations.
# Currently the only cached variable is ${proj}_SOURCE_DIR (but it'd be easy to change that)
#
# Example usage for a project once it's included:
#   cmake . -DSTIR_SOURCE_DIR:PATH=~/devel/STIR

macro(SetCanonicalDirectoryNames proj)
  set(${proj}_SOURCE_DIR "${SOURCE_ROOT_DIR}/${proj}" CACHE PATH "Source directory for ${proj}")
  mark_as_advanced(${proj}_SOURCE_DIR)
  set(${proj}_BINARY_DIR "${SUPERBUILD_WORK_DIR}/builds/${proj}/build" )
  set(${proj}_DOWNLOAD_DIR "${SUPERBUILD_WORK_DIR}/downloads/${proj}" )
  set(${proj}_STAMP_DIR "${SUPERBUILD_WORK_DIR}/builds/${proj}/stamp" )
  set(${proj}_TMP_DIR "${SUPERBUILD_WORK_DIR}/builds/${proj}/tmp" )
  set(${proj}_INSTALL_DIR ${SUPERBUILD_INSTALL_DIR})

  # set a variable to use in the ExternalProject_Add call that sets all these variables
  set(${proj}_EP_ARGS_DIRS
    SOURCE_DIR ${${proj}_SOURCE_DIR}
    BINARY_DIR ${${proj}_BINARY_DIR}
    DOWNLOAD_DIR ${${proj}_DOWNLOAD_DIR}
    STAMP_DIR ${${proj}_STAMP_DIR}
    TMP_DIR ${${proj}_TMP_DIR}
    INSTALL_DIR ${${proj}_INSTALL_DIR}
  )
endmacro()
