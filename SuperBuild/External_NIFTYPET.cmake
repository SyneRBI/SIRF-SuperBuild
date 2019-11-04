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

#This needs to be unique globally
set(proj NIFTYPET)

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
  set(SIRF_Install_Dir ${SUPERBUILD_INSTALL_DIR})

  IF(NOT ${PYTHON_VERSION_MAJOR} EQUAL 2)
    MESSAGE(FATAL_ERROR "${proj} currently only works with python version 2.")
  endif()

  set(NIFTYPET_INSTALL_COMMAND ${CMAKE_SOURCE_DIR}/CMake/install_niftypet.cmake)

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    GIT_REPOSITORY "${${proj}_URL}"
    GIT_TAG "${${proj}_TAG}"
    SOURCE_DIR ${${proj}_SOURCE_DIR}
    BINARY_DIR ${${proj}_BINARY_DIR}
    DOWNLOAD_DIR ${${proj}_DOWNLOAD_DIR}
    STAMP_DIR ${${proj}_STAMP_DIR}
    TMP_DIR ${${proj}_TMP_DIR}
    SOURCE_SUBDIR niftypet

    CMAKE_ARGS
      -DCMAKE_C_COMPILER="${CMAKE_C_COMPILER}"
      -DCMAKE_CXX_COMPILER="${CMAKE_CXX_COMPILER}"
      -DCMAKE_PREFIX_PATH=${SUPERBUILD_INSTALL_DIR}
      -DCMAKE_LIBRARY_PATH=${SUPERBUILD_INSTALL_DIR}/lib
      -DCMAKE_INSTALL_PREFIX=${SIRF_Install_Dir}
      -DPYTHON_EXECUTABLE=${PYTHON_EXECUTABLE}
      -DPYTHON_INCLUDE_DIR=${PYTHON_INCLUDE_DIR}
      -DPYTHON_LIBRARY=${PYTHON_LIBRARY}

    DEPENDS
        ${${proj}_DEPENDENCIES}

    INSTALL_COMMAND ${CMAKE_COMMAND}
      -D${proj}_SOURCE_DIR=${${proj}_SOURCE_DIR}
      -D${proj}_BINARY_DIR=${${proj}_BINARY_DIR}
      -DSUPERBUILD_INSTALL_DIR=${SUPERBUILD_INSTALL_DIR}
      -P ${NIFTYPET_INSTALL_COMMAND}
  )

    set(${proj}_PETPRJ_LIB "${SUPERBUILD_INSTALL_DIR}/lib/petprj.so")
    set(${proj}_MMR_AUXE_LIB "${SUPERBUILD_INSTALL_DIR}/lib/mmr_auxe.so")
    set(${proj}_INCLUDE_DIR "${SUPERBUILD_INSTALL_DIR}/include")


   else()
      if(${USE_SYSTEM_${externalProjName}})
        FIND_LIBRARY(${proj}_PETPRJ_LIB mmr_auxe)
        FIND_LIBRARY(${proj}_MMR_AUXE_LIB petprj)
        set(${proj}_INCLUDE_DIR "" CACHE PATH "Path to NiftyPET include dir. Set this to top level of source code if unsure.")
        if (NOT ${proj}_PETPRJ_LIB)
          MESSAGE(FATAL_ERROR "${proj} projector library (libpetprj) not found.")
        endif()
        if (NOT ${proj}_MMR_AUXE_LIB)
          MESSAGE(FATAL_ERROR "${proj} projector library (libmmr_auxe) not found.")
        endif()
        if (NOT EXISTS "${${proj}_INCLUDE_DIR}/niftypet/nipet/prj/src/prjf.h")
          MESSAGE(FATAL_ERROR "${proj} source directory incorrect
            (${${proj}_INCLUDE_DIR}/niftypet/nipet/prj/src/prjf.h doesn't exist).")
        endif()

        message(STATUS "USING the system ${externalProjName}, set ${externalProjName}_DIR=${${externalProjName}_DIR}")
   endif()
    ExternalProject_Add_Empty(${proj} DEPENDS "${${proj}_DEPENDENCIES}"
      SOURCE_DIR ${${proj}_SOURCE_DIR}
      BINARY_DIR ${${proj}_BINARY_DIR}
      DOWNLOAD_DIR ${${proj}_DOWNLOAD_DIR}
      STAMP_DIR ${${proj}_STAMP_DIR}
      TMP_DIR ${${proj}_TMP_DIR}
    )
  endif()

  mark_as_superbuild(
    VARS
      ${externalProjName}_DIR:PATH
    LABELS
      "FIND_PACKAGE"
  )
