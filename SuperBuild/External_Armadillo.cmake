#========================================================================
# Author: Benjamin A Thomas
# Author: Kris Thielemans
# Author: Edoardo Pasca
# Copyright 2017 University College London
# Copyright 2017 Science Technology Facilities Council
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

# Add Armadillo
#
# Warning: CMake's FindArmadillo.cmake will always search in default CMake paths and cannot be
# forced to search first in an alternative location (e.g. via ARMADILLO_ROOT or so).
# Therefore future find_package statements might still find the system one even if you
# build your own.

#This needs to be unique globally
set(proj Armadillo)

# Set dependency list
set(${proj}_DEPENDENCIES "")

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

  ### --- Project specific additions here
  set(${proj}_Install_Dir ${SUPERBUILD_INSTALL_DIR})


  # name after extraction
  set(${proj}_location Armadillo)

  if(CMAKE_COMPILER_IS_CLANGXX)
    set(CLANG_ARG -DCMAKE_COMPILER_IS_CLANGXX:BOOL=ON)
  endif()

  #set(${proj}_SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj}-prefix/src/${${proj}_location} )



  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    URL ${${proj}_URL}
    URL_HASH MD5=${${proj}_MD5}

    SOURCE_DIR ${${proj}_SOURCE_DIR}
    BINARY_DIR ${${proj}_BINARY_DIR}
    DOWNLOAD_DIR ${${proj}_DOWNLOAD_DIR}
    STAMP_DIR ${${proj}_STAMP_DIR}
    TMP_DIR ${${proj}_TMP_DIR}

    #CONFIGURE_COMMAND ${CMAKE_COMMAND}
    #                         ${CLANG_ARG}
    #                         -DCMAKE_INSTALL_PREFIX:PATH=${${proj}_Install_Dir} "${${proj}_SOURCE_DIR}"
    CMAKE_ARGS
      -DCMAKE_PREFIX_PATH=${SUPERBUILD_INSTALL_DIR}
      -DCMAKE_INSTALL_PREFIX=${${proj}_Install_Dir}
      ${CLANG_ARG}

    INSTALL_DIR ${${proj}_Install_Dir}
  )

  # no point doing this as FindArmadillo doesn't honour any *_ROOT or *_DIR settings
  #set( ARMADILLO_ROOT ${${proj}_Install_Dir} )
  #set(ARMADILLO_INCLUDE_DIRS ${${proj}_Install_Dir}/include )
  # Instead, it might be possible to set ARMADILLO_INCLUDE_DIR and ARMADILLO_LIBRARY
  # as cached variables such that find_library doesn't attempt to find them again.
  # We haven't tried this, and it doesn't seem to be needed.
 else()
    if(${USE_SYSTEM_${externalProjName}})
      find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} REQUIRED)
      message(STATUS "USING the system ${externalProjName}, found ARMADILLO_LIBRARIES=${ARMADILLO_LIBRARIES}}")
  endif()
  ExternalProject_Add_Empty(${proj} DEPENDS "${${proj}_DEPENDENCIES}"
    SOURCE_DIR ${${proj}_SOURCE_DIR}
    BINARY_DIR ${${proj}_BINARY_DIR}
    DOWNLOAD_DIR ${${proj}_DOWNLOAD_DIR}
    STAMP_DIR ${${proj}_STAMP_DIR}
    TMP_DIR ${${proj}_TMP_DIR}
  )
endif()

# no point doing this as FindArmadillo doesn't honour any *_ROOT or *_DIR settings
#mark_as_superbuild(
#  ALL_PROJECTS
#  VARS
#    ${externalProjName}_DIR:PATH
#  LABELS
#    "FIND_PACKAGE"
#)
