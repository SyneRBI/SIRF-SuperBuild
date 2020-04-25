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
set(proj NIFTYPET)

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

  IF(NOT ${PYTHON_VERSION_MAJOR} EQUAL 2)
    MESSAGE(FATAL_ERROR "${proj} currently only works with python version 2.")
  endif()

  set(NIFTYPET_INSTALL_COMMAND ${CMAKE_SOURCE_DIR}/CMake/install_niftypet.cmake)

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
      -DPYTHON_EXECUTABLE=${PYTHON_EXECUTABLE}
      -DPYTHON_INCLUDE_DIR:PATH=${PYTHON_INCLUDE_DIR}
      -DPYTHON_LIBRARY=${PYTHON_LIBRARY}
      ${${proj}_EXTRA_CMAKE_ARGS_LIST}
    DEPENDS
        ${${proj}_DEPENDENCIES}

    INSTALL_COMMAND ${CMAKE_COMMAND}
      -D${proj}_SOURCE_DIR:PATH=${${proj}_SOURCE_DIR}
      -D${proj}_BINARY_DIR:PATH=${${proj}_BINARY_DIR}
      -DSUPERBUILD_INSTALL_DIR:PATH=${SUPERBUILD_INSTALL_DIR}
      -P ${NIFTYPET_INSTALL_COMMAND}
  )

    set(${proj}_PETPRJ_LIB "${SUPERBUILD_INSTALL_DIR}/lib/petprj.so")
    set(${proj}_MMR_AUXE_LIB "${SUPERBUILD_INSTALL_DIR}/lib/mmr_auxe.so")
    set(${proj}_MMR_LMPROC_LIB "${SUPERBUILD_INSTALL_DIR}/lib/mmr_lmproc.so")
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
        ${${proj}_EP_ARGS_DIRS}
    )
  endif()

  mark_as_superbuild(
    VARS
      ${externalProjName}_DIR:PATH
    LABELS
      "FIND_PACKAGE"
  )
