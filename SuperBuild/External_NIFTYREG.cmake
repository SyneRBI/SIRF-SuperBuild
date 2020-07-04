#========================================================================
# Author: Richard Brown
# Author: Benjamin A Thomas
# Author: Kris Thielemans
# Copyright 2017, 2020 University College London
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
set(proj NIFTYREG)

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

  #message(STATUS "HDF5_ROOT in External_SIRF: " ${HDF5_ROOT})
  set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} ${SUPERBUILD_INSTALL_DIR})
  set(CMAKE_INCLUDE_PATH ${CMAKE_INCLUDE_PATH} ${SUPERBUILD_INSTALL_DIR})

  option(${proj}_USE_CUDA "Enable ${proj} CUDA (if cuda libraries are present)" ${${proj}_USE_CUDA})
  mark_as_advanced(${proj}_USE_CUDA)

  # Sets ${proj}_URL_MODIFIED and ${proj}_TAG_MODIFIED
  SetGitTagAndRepo("${proj}")

  if (NOT DISABLE_OpenMP)
    option(${proj}_ENABLE_OPENMP "Build ${proj} with OpenMP acceleration" ON)
  else()
    SET(${proj}_ENABLE_OPENMP OFF)
  endif()

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    ${${proj}_EP_ARGS_GIT}
    ${${proj}_EP_ARGS_DIRS}
    CMAKE_ARGS
      -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=${CMAKE_POSITION_INDEPENDENT_CODE}
      -DCMAKE_PREFIX_PATH:PATH=${SUPERBUILD_INSTALL_DIR}
      -DCMAKE_LIBRARY_PATH:PATH=${SUPERBUILD_INSTALL_DIR}/lib
      -DCMAKE_INCLUDE_PATH:PATH=${SUPERBUILD_INSTALL_DIR}
      -DCMAKE_INSTALL_PREFIX:PATH=${${proj}_Install_Dir}
      -DUSE_THROW_EXCEP:BOOL=ON
      # fixes lib_reg_maths.a `GOMP_parallel' undefined reference linker errors
      -DUSE_OPENMP:BOOL=${${proj}_ENABLE_OPENMP}
      -DBUILD_ALL_DEP:BOOL=ON
      -DUSE_CUDA:BOOL=${${proj}_USE_CUDA}
       ${${proj}_EXTRA_CMAKE_ARGS_LIST}
    DEPENDS ${${proj}_DEPENDENCIES})

    set(${proj}_ROOT        ${${proj}_SOURCE_DIR})
    set(${proj}_INCLUDE_DIR ${${proj}_SOURCE_DIR})
    set(${proj}_DIR "${SUPERBUILD_INSTALL_DIR}/lib/cmake/NiftyReg")
   else()
      if(${USE_SYSTEM_${externalProjName}})
        find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} REQUIRED)
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
