#========================================================================
# Author: Benjamin A Thomas
# Author: Kris Thielemans
# Author: Edoardo Pasca
# Copyright 2017, 2020 University College London
# Copyright 2017, 2020 STFC
#
# This file is part of the CCP SyneRBI (formerly PETMR) Synergistic Image Reconstruction Framework (SIRF) SuperBuild.
##
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
set(proj SWIG)

# Set dependency list
set(${proj}_DEPENDENCIES "")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})

SetCanonicalDirectoryNames(${proj})

if (WIN32)
  set(SWIG_INSTALL_DIR ${SUPERBUILD_INSTALL_DIR}/SWIG-3.0.12)
  set(SB_SWIG_EXECUTABLE ${SWIG_INSTALL_DIR}/swig.exe)
else(WIN32)
  set(SWIG_INSTALL_DIR ${SUPERBUILD_INSTALL_DIR})
  set(SB_SWIG_EXECUTABLE ${SWIG_INSTALL_DIR}/bin/swig)
endif()

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here

  if (WIN32)

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    URL ${${proj}_URL}
    URL_HASH MD5=${${proj}_MD5}
    ${${proj}_EP_ARGS_DIRS}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory ${SWIG_INSTALL_DIR}
        COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> ${SWIG_INSTALL_DIR}
  )
  set( SWIG_EXECUTABLE ${SB_SWIG_EXECUTABLE} CACHE FILEPATH "SWIG executable" FORCE)

  else(WIN32)

  set(SWIG_Configure_Script ${CMAKE_CURRENT_LIST_DIR}/External_SWIG_configure.cmake)
  set(SWIG_Build_Script ${CMAKE_CURRENT_LIST_DIR}/External_SWIG_build.cmake)

  if(CMAKE_COMPILER_IS_CLANGXX)
    set(CLANG_ARG -DCMAKE_COMPILER_IS_CLANGXX:BOOL=ON)
  endif()

  set(SWIG_SOURCE_DIR ${${proj}_SOURCE_DIR} )

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    URL ${${proj}_URL}
    URL_HASH MD5=${${proj}_MD5}
    ${${proj}_EP_ARGS_DIRS}

    CONFIGURE_COMMAND ${${proj}_SOURCE_DIR}/configure --without-pcre --prefix ${SWIG_INSTALL_DIR}
    INSTALL_DIR ${${proj}_INSTALL_DIR}
  )

  set( SWIG_EXECUTABLE ${SB_SWIG_EXECUTABLE} CACHE FILEPATH "SWIG executable" FORCE)

  endif(WIN32)

 else()
    if(${USE_SYSTEM_${externalProjName}})
      # Check if the SWIG_EXECUTABLE has already been set from a previous run, when USE_SYSTEM_SWIG=OFF
      # If this is the case, and the executable doesn't exist (presumably because cmake was run, but make SWIG
      # hadn't been run yet), then unset the SWIG_EXECUTABLE value
      if("${SWIG_EXECUTABLE}" STREQUAL "${SB_SWIG_EXECUTABLE}" AND NOT EXISTS "${SWIG_EXECUTABLE}")
        unset(SWIG_EXECUTABLE CACHE)
      endif()
      find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} ${${externalProjName}_COMPONENTS} REQUIRED)
      message(STATUS "USING the system ${externalProjName}, found SWIG_EXECUTABLE=${SWIG_EXECUTABLE}, SWIG_VERSION=${SWIG_VERSION}")
  endif()
  ExternalProject_Add_Empty(${proj} DEPENDS "${${proj}_DEPENDENCIES}"
    ${${proj}_EP_ARGS_DIRS}
  )
endif()

mark_as_superbuild(
  ALL_PROJECTS
  VARS
    SWIG_EXECUTABLE:FILEPATH
  LABELS
    "FIND_PACKAGE"
)
