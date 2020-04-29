#========================================================================
# Author: Richard Brown
# Copyright 2017, 2020 University College London
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
set(proj NiftyPET)

# Set dependency list
set(${proj}_DEPENDENCIES "")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})

SetCanonicalDirectoryNames(${proj})
# Get any flag from the superbuild call that may be particular to this projects CMAKE_ARGS
SetExternalProjectFlags(${proj})

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here

  IF(${PYTHON_VERSION_MAJOR} EQUAL 2)
    SET(NiftyPET_PYTHON_EXECUTABLE ${PYTHON_EXECUTABLE} CACHE PATH "Path to python2 executable for NiftyPET installation")
    SET(NiftyPET_PYTHON_INCLUDE_DIR ${PYTHON_INCLUDE_DIR} CACHE PATH "Path to python2 include directories for NiftyPET installation")
    SET(NiftyPET_PYTHON_LIBRARY ${PYTHON_LIBRARY} CACHE PATH "Path to python2 libraries for NiftyPET installation")
  ELSE()
    message(STATUS "NiftyPET currently only supports python2,"
      " so using that for NiftyPET compilation...")
    find_package (Python2 REQUIRED COMPONENTS Interpreter Development)
    SET(NiftyPET_PYTHON_EXECUTABLE ${Python2_EXECUTABLE} CACHE PATH "Path to python2 executable for NiftyPET installation")
    SET(NiftyPET_PYTHON_INCLUDE_DIR ${Python2_INCLUDE_DIRS} CACHE PATH "Path to python2 include directories for NiftyPET installation")
    SET(NiftyPET_PYTHON_LIBRARY ${Python2_LIBRARIES} CACHE PATH "Path to python2 libraries for NiftyPET installation")
  ENDIF()
  mark_as_advanced(NiftyPET_PYTHON_EXECUTABLE
    NiftyPET_PYTHON_INCLUDE_DIR
    NiftyPET_PYTHON_LIBRARY)

  set(NiftyPET_INSTALL_COMMAND ${CMAKE_SOURCE_DIR}/CMake/install_NiftyPET.cmake)

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    GIT_REPOSITORY "${${proj}_URL}"
    GIT_TAG "${${proj}_TAG}"
    ${${proj}_EP_ARGS_DIRS}
    SOURCE_SUBDIR niftypet

    CMAKE_ARGS
      -DCMAKE_PREFIX_PATH=${SUPERBUILD_INSTALL_DIR}
      -DCMAKE_LIBRARY_PATH=${SUPERBUILD_INSTALL_DIR}/lib
      -DCMAKE_INSTALL_PREFIX=${${proj}_INSTALL_DIR}
      -DPYTHON_EXECUTABLE=${NiftyPET_PYTHON_EXECUTABLE}
      -DPYTHON_INCLUDE_DIR:PATH=${NiftyPET_PYTHON_INCLUDE_DIR}
      -DPYTHON_LIBRARY=${NiftyPET_PYTHON_LIBRARY}
      ${${proj}_EXTRA_CMAKE_ARGS_LIST}
    DEPENDS
        ${${proj}_DEPENDENCIES}

    INSTALL_COMMAND ${CMAKE_COMMAND}
      -D${proj}_SOURCE_DIR:PATH=${${proj}_SOURCE_DIR}
      -D${proj}_BINARY_DIR:PATH=${${proj}_BINARY_DIR}
      -DSUPERBUILD_INSTALL_DIR:PATH=${SUPERBUILD_INSTALL_DIR}
      -P ${NiftyPET_INSTALL_COMMAND}
  )

  set(${proj}_PATH "${SUPERBUILD_INSTALL_DIR}")

else()
  if(${USE_SYSTEM_${externalProjName}})
    if (NOT ${proj}_PATH)
      SET(${proj}_PATH "" CACHE PATH "Path to ${proj} installation")
      MESSAGE(FATAL_ERROR "${proj}_PATH not set.")
    endif()
    find_package(NiftyPET REQUIRED)
  endif()
  ExternalProject_Add_Empty(${proj} DEPENDS "${${proj}_DEPENDENCIES}"
    ${${proj}_EP_ARGS_DIRS}
  )
endif()

mark_as_superbuild(
  VARS
    ${externalProjName}_PATH:PATH
  LABELS
    "FIND_PACKAGE"
)
