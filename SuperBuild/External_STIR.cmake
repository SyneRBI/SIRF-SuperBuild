#========================================================================
# Author: Benjamin A Thomas
# Author: Kris Thielemans
# Copyright 2017 University College London
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
set(proj STIR)

# Set dependency list
set(${proj}_DEPENDENCIES "Boost")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here
  set(STIR_Install_Dir ${SUPERBUILD_INSTALL_DIR})


  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    GIT_REPOSITORY ${${proj}_URL}
    GIT_TAG ${STIR_TAG}
    SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj}
    CMAKE_ARGS -DGRAPHICS=None
        -DBUILD_EXECUTABLES=OFF
        -DBUILD_TESTING=OFF
        -DBUILD_DOCUMENTATION=OFF
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON
        -DBOOST_ROOT=${BOOST_ROOT}
        -DCMAKE_INSTALL_PREFIX=${STIR_Install_Dir}
        -DGRAPHICS=None
        -DCMAKE_CXX_STANDARD=11
        -DSTIR_USE_BOOST_SHARED_PTR=On
    INSTALL_DIR ${STIR_Install_Dir}
    DEPENDS
        ${${proj}_DEPENDENCIES}
  )

  set(STIR_ROOT       ${STIR_Install_Dir})
  set(STIR_DIR       ${SUPERBUILD_INSTALL_DIR}/lib/cmake)
  set(STIR_INCLUDE_DIRS ${STIR_ROOT}/stir)

   else()
      if(${USE_SYSTEM_${externalProjName}})
        find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} REQUIRED)
        message("USING the system ${externalProjName}, set ${externalProjName}_DIR=${${externalProjName}_DIR}")
    endif()
    ExternalProject_Add_Empty(${proj} "${${proj}_DEPENDENCIES}")
  endif()

  mark_as_superbuild(
    VARS
      ${externalProjName}_DIR:PATH
    LABELS
      "FIND_PACKAGE"
  )
