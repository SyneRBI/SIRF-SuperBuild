#========================================================================
# Author: Richard Brown
# Copyright 2020 UCL
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

#This needs to be unique globally
set(proj SPM)

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})
SetCanonicalDirectoryNames(${proj})


if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  SetGitTagAndRepo("${proj}")

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    ${${proj}_EP_ARGS_GIT}
    ${${proj}_EP_ARGS_DIRS}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
  )

  set(${proj}_DIR ${${proj}_SOURCE_DIR} CACHE PATH "SPM DIR")

else()
  find_package(${proj} REQUIRED)
  message(STATUS "USING the system ${externalProjName}, set ${externalProjName}_DIR=${${externalProjName}_DIR}")
  ExternalProject_Add_Empty(${proj} DEPENDS "${${proj}_DEPENDENCIES}"
                            ${${proj}_EP_ARGS_DIRS}
  )
endif()
