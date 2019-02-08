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
set(proj SIRF)

# Set dependency list
if (${BUILD_NiftyReg})
  set(${proj}_DEPENDENCIES "STIR;Boost;HDF5;ISMRMRD;FFTW3;SWIG;NiftyReg")
else()
  set(${proj}_DEPENDENCIES "STIR;Boost;HDF5;ISMRMRD;FFTW3;SWIG")
endif()

message(STATUS "Matlab_ROOT_DIR=" ${Matlab_ROOT_DIR})
message(STATUS "STIR_DIR=" ${STIR_DIR})
message(STATUS "NiftyReg_Binary_DIR=" ${NiftyReg_Binary_DIR})

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

  option(BUILD_TESTING_${proj} "Build tests for ${proj}" ON)

  message(STATUS "HDF5_ROOT in External_SIRF: " ${HDF5_ROOT})
  set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} ${SUPERBUILD_INSTALL_DIR})

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
        -DCMAKE_PREFIX_PATH=${SUPERBUILD_INSTALL_DIR}
        -DCMAKE_LIBRARY_PATH=${SUPERBUILD_INSTALL_DIR}/lib
        -DCMAKE_INSTALL_PREFIX=${SIRF_Install_Dir}
        -DBOOST_INCLUDEDIR=${BOOST_ROOT}/include/
        -DBOOST_LIBRARYDIR=${BOOST_LIBRARY_DIR}
        -DBOOST_ROOT=${BOOST_ROOT}
        -DMatlab_ROOT_DIR=${Matlab_ROOT_DIR}
        -DMATLAB_ROOT=${Matlab_ROOT_DIR} # pass this for compatibility with old SIRF
        -DMATLAB_DEST_DIR=${MATLAB_DEST_DIR}
        -DSTIR_DIR=${STIR_DIR}
        -DHDF5_ROOT=${HDF5_ROOT}
        -DHDF5_INCLUDE_DIRS=${HDF5_INCLUDE_DIRS}
        -DISMRMRD_DIR=${ISMRMRD_DIR}
        -DSWIG_EXECUTABLE=${SWIG_EXECUTABLE}
        -DPYTHON_EXECUTABLE=${PYTHON_EXECUTABLE}
        -DPYTHON_INCLUDE_DIR=${PYTHON_INCLUDE_DIRS}
        -DPYTHON_LIBRARY=${PYTHON_LIBRARIES}
        -DPYTHON_DEST_DIR=${PYTHON_DEST_DIR}
        -DPYTHON_STRATEGY=${PYTHON_STRATEGY}
        -DNiftyReg_Binary_DIR=${NiftyReg_Binary_DIR}
	INSTALL_DIR ${SIRF_Install_Dir}
    DEPENDS
        ${${proj}_DEPENDENCIES}
  )

    set(SIRF_ROOT        ${SIRF_SOURCE_DIR})
    set(SIRF_INCLUDE_DIR ${SIRF_SOURCE_DIR})

  #if (BUILD_TESTING_${proj})
    add_test(NAME ${proj}_TESTS
         COMMAND ${CMAKE_CTEST_COMMAND} -C $<CONFIGURATION>
         WORKING_DIRECTORY ${${proj}_BINARY_DIR})
  #endif()

   else()
      if(${USE_SYSTEM_${externalProjName}})
        find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} REQUIRED)
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
