#========================================================================
# Author: Benjamin A Thomas
# Author: Kris Thielemans
# Author: Edoardo Pasca
# Author: Casper da Costa-Luis
# Copyright 2017, 2020 University College London
# Copyright 2017, 2020 STFC
# Copyright 2019, 2020 King's College London
#
# This file is part of the CCP SyneRBI (formely PETMR) Synergistic Image Reconstruction Framework (SIRF) SuperBuild.
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
set(proj TomoPhantom)

# Set dependency list
set(${proj}_DEPENDENCIES "")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})

# Get any flag from the superbuild call that may be particular to this projects CMAKE_ARGS
SetExternalProjectFlags(${proj})


set(${proj}_SOURCE_DIR "${SOURCE_ROOT_DIR}/${proj}" )
set(${proj}_BINARY_DIR "${SUPERBUILD_WORK_DIR}/builds/${proj}/build" )
set(${proj}_DOWNLOAD_DIR "${SUPERBUILD_WORK_DIR}/downloads/${proj}" )
set(${proj}_STAMP_DIR "${SUPERBUILD_WORK_DIR}/builds/${proj}/stamp" )
set(${proj}_TMP_DIR "${SUPERBUILD_WORK_DIR}/builds/${proj}/tmp" )

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here
  set(TomoPhantom_Install_Dir ${SUPERBUILD_INSTALL_DIR})

  set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} ${SUPERBUILD_INSTALL_DIR})
  set(CMAKE_INCLUDE_PATH ${CMAKE_INCLUDE_PATH} ${SUPERBUILD_INSTALL_DIR})



  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    GIT_REPOSITORY ${${proj}_URL}
    GIT_TAG ${${proj}_TAG}
    SOURCE_DIR ${${proj}_SOURCE_DIR}
    BINARY_DIR ${${proj}_BINARY_DIR}
    DOWNLOAD_DIR ${${proj}_DOWNLOAD_DIR}
    STAMP_DIR ${${proj}_STAMP_DIR}
    TMP_DIR ${${proj}_TMP_DIR}

    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX=${TomoPhantom_Install_Dir}
    	-DLIBRARY_DIR:PATH=${TomoPhantom_Install_Dir}/lib
    	-DINCLUDE_DIR:PATH=${TomoPhantom_Install_Dir}/include
    	-DCONDA_BUILD=OFF
    	-DBUILD_PYTHON_WRAPPER=ON
    	-DCMAKE_BUILD_TYPE=Release
    	-DPYTHON_EXECUTABLE=${PYTHON_EXECUTABLE}
    	-DPYTHON_INCLUDE_DIR:PATH=${PYTHON_INCLUDE_DIRS}
    	-DPYTHON_LIBRARY=${PYTHON_LIBRARIES}
    	-DPYTHON_DEST_DIR:PATH=${PYTHON_DEST_DIR}
    	-DPYTHON_STRATEGY=${PYTHON_STRATEGY}
      ${${proj}_EXTRA_CMAKE_ARGS_LIST}
    # TODO this relies on using "make", but we could be build with something else
    #INSTALL_COMMAND make TomoPhantom
    DEPENDS
        ${${proj}_DEPENDENCIES}
  )

   # not used
   # set(${proj}_ROOT        ${${proj}_SOURCE_DIR})
   # set(${proj}_INCLUDE_DIR ${${proj}_SOURCE_DIR})

   else()
      if(${USE_SYSTEM_${externalProjName}})
        find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} REQUIRED)
        message(STATUS "USING the system ${externalProjName}, found ACE_LIBRARIES=${ACE_LIBRARIES}")
    endif()
  ExternalProject_Add_Empty(${proj} DEPENDS "${${proj}_DEPENDENCIES}"
    SOURCE_DIR ${${proj}_SOURCE_DIR}
    BINARY_DIR ${${proj}_BINARY_DIR}
    DOWNLOAD_DIR ${${proj}_DOWNLOAD_DIR}
    STAMP_DIR ${${proj}_STAMP_DIR}
    TMP_DIR ${${proj}_TMP_DIR}
  )
  endif()
