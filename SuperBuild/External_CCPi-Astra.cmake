#========================================================================
# Author: Edoardo Pasca
# Copyright 2019, 2020 STFC
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
set(proj CCPi-Astra)

# Set dependency list
set(${proj}_DEPENDENCIES "CCPi-Framework;astra-toolbox")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})
SetCanonicalDirectoryNames(${proj})


if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")
  SetGitTagAndRepo("${proj}")

  ### --- Project specific additions here
  # set(libcilreg_Install_Dir ${SUPERBUILD_INSTALL_DIR})

  # #message(STATUS "HDF5_ROOT in External_SIRF: " ${HDF5_ROOT})
  # set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} ${SUPERBUILD_INSTALL_DIR})
  # set(CMAKE_INCLUDE_PATH ${CMAKE_INCLUDE_PATH} ${SUPERBUILD_INSTALL_DIR})


  message("${proj} URL " ${${proj}_URL}  )
  message("${proj} TAG " ${${proj}_TAG}  )
  # conda build should never get here
  if("${PYTHON_STRATEGY}" STREQUAL "PYTHONPATH")
    # in case of PYTHONPATH it is sufficient to copy the files to the
    # $PYTHONPATH directory
    ExternalProject_Add(${proj}
      ${${proj}_EP_ARGS}
      ${${proj}_EP_ARGS_GIT}
      ${${proj}_EP_ARGS_DIRS}

      CONFIGURE_COMMAND ""
      BUILD_COMMAND ""
      INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory ${${proj}_SOURCE_DIR}/Wrappers/Python/cil/plugins/astra ${PYTHON_DEST}/cil/plugins/astra
      CMAKE_ARGS -DCMAKE_INSTALL_PREFIX:PATH=${${proj}_INSTALL_DIR}
      DEPENDS ${${proj}_DEPENDENCIES}
    )

  else()
    # if SETUP_PY one can launch the conda build.sh script setting
    # the appropriate variables.
    message(FATAL_ERROR "Only PYTHONPATH install method is currently supported")
  endif()


  set(${proj}_ROOT        ${${proj}_SOURCE_DIR})
  set(${proj}_INCLUDE_DIR ${${proj}_SOURCE_DIR})

else()
  ExternalProject_Add_Empty(${proj} DEPENDS "${${proj}_DEPENDENCIES}"
                            ${${proj}_EP_ARGS_DIRS}
  )
endif()
