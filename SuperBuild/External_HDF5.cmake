#========================================================================
# Author: Benjamin A Thomas
# Author: Kris Thielemans
# Author: Edoardo Pasca
# Copyright 2017 University College London
# Copyright 2017 STFC
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
#These need to be unique globally
set(proj HDF5)

# Set dependency list
set(${proj}_DEPENDENCIES "")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here
  set(HDF5_Install_Dir ${SUPERBUILD_INSTALL_DIR})

  if(CMAKE_COMPILER_IS_CLANGXX)
    set(CLANG_ARG -DCMAKE_COMPILER_IS_CLANGXX:BOOL=ON)
  endif()

  #set(HDF5_SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj}-prefix/src/HDF5/hdf5-1.10.0-patch1 )
  set(${proj}_SOURCE_DIR "${SOURCE_DOWNLOAD_CACHE}/Source/${proj}" )
  set(${proj}_BINARY_DIR "${SOURCE_DOWNLOAD_CACHE}/Build/${proj}" )
  set(${proj}_DOWNLOAD_DIR "${SOURCE_DOWNLOAD_CACHE}/Download/${proj}" )
  set(${proj}_STAMP_DIR "${SOURCE_DOWNLOAD_CACHE}/Stamp/${proj}" )
  set(${proj}_TMP_DIR "${SOURCE_DOWNLOAD_CACHE}/tmp/${proj}" )
  
  
  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    URL ${${proj}_URL}
    URL_HASH MD5=${${proj}_MD5}

    SOURCE_DIR ${${proj}_SOURCE_DIR}
    BINARY_DIR ${${proj}_BINARY_DIR}
    DOWNLOAD_DIR ${${proj}_DOWNLOAD_DIR}
    STAMP_DIR ${${proj}_STAMP_DIR}
    TMP_DIR ${${proj}_TMP_DIR}

	
    CMAKE_ARGS
        ${CLANG_ARG}
        -DHDF5_BUILD_EXAMPLES=OFF 
        -DHDF5_BUILD_TOOLS=OFF 
        -DHDF5_BUILD_HL_LIB=OFF 
        -DBUILD_TESTING=OFF
    INSTALL_DIR ${HDF5_Install_Dir}
  )

  set( HDF5_ROOT ${HDF5_Install_Dir} )
  set( HDF5_INCLUDE_DIRS ${HDF5_ROOT}/include )

 else()
    if(${USE_SYSTEM_${externalProjName}})
      find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} REQUIRED)
      message(STATUS "USING the system ${externalProjName}, found HDF5_INCLUDE_DIRS=${HDF5_INCLUDE_DIRS}, HDF5_C_LIBRARY_hdf5=${HDF5_C_LIBRARY_hdf5},HDF5_LIBRARIES=${HDF5_LIBRARIES}")
  endif()
  ExternalProject_Add_Empty(${proj} DEPENDS "${${proj}_DEPENDENCIES}")
endif()

mark_as_superbuild(
  VARS
    ${externalProjName}_DIR:PATH
  LABELS
    "FIND_PACKAGE"
)
