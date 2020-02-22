#========================================================================
# Author: Richard Brown
# Copyright 2020 UCL
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

#This needs to be unique globally
set(proj SPM)

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})

set(${proj}_SOURCE_DIR "${SOURCE_ROOT_DIR}/${proj}" )
set(${proj}_BINARY_DIR "${SUPERBUILD_WORK_DIR}/builds/${proj}/build" )
set(${proj}_DOWNLOAD_DIR "${SUPERBUILD_WORK_DIR}/downloads/${proj}" )
set(${proj}_STAMP_DIR "${SUPERBUILD_WORK_DIR}/builds/${proj}/stamp" )
set(${proj}_TMP_DIR "${SUPERBUILD_WORK_DIR}/builds/${proj}/tmp" )

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    GIT_REPOSITORY ${${proj}_URL}
    GIT_TAG ${${proj}_TAG}
    SOURCE_DIR ${${proj}_SOURCE_DIR}
    BINARY_DIR ${${proj}_BINARY_DIR}
    DOWNLOAD_DIR ${${proj}_DOWNLOAD_DIR}
    STAMP_DIR ${${proj}_STAMP_DIR}
    TMP_DIR ${${proj}_TMP_DIR}
    INSTALL_DIR ${SUPERBUILD_INSTALL_DIR}
  
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
  )

  set(${proj}_DIR ${${proj}_SOURCE_DIR} CACHE PATH "SPM DIR")

else()
  if(${USE_SYSTEM_${externalProjName}})
    find_package(${proj} REQUIRED)
    message(STATUS "USING the system ${externalProjName}, set ${externalProjName}_DIR=${${externalProjName}_DIR}")
  endif()
endif()
