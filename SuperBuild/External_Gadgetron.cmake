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

#This needs to be unique globally
set(proj Gadgetron)

# Set dependency list
set(${proj}_DEPENDENCIES "ACE;Boost;HDF5;ISMRMRD;FFTW3double;Armadillo;GTest")

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
  set(Gadgetron_Install_Dir ${SUPERBUILD_INSTALL_DIR})

  # Gadgetron only adds tests if (GTEST_FOUND AND ARMADILLO_FOUND)
  # but that's currently always the case.
  # Default to on, as we cannot disable it, and they're quite fast
  option(BUILD_TESTING_${proj} "Build tests for ${proj}" ON)

  #message(STATUS "HDF5_ROOT in External_SIRF: " ${HDF5_ROOT})
  set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} ${SUPERBUILD_INSTALL_DIR})
  set(CMAKE_INCLUDE_PATH ${CMAKE_INCLUDE_PATH} ${SUPERBUILD_INSTALL_DIR})

  # BLAS
  find_package(BLAS)
  if (APPLE AND NOT (CBLAS_LIBRARY AND CBLAS_INCLUDE_DIR))
	# if the variables don't exist, let the user set them.
	SET(CBLAS_LIBRARY "" CACHE FILEPATH "CBAS library")
	SET(CBLAS_INCLUDE_DIR "" CACHE PATH "CBAS include directory")
    message(FATAL_ERROR "Gadgetron needs CBLAS_LIBRARY and CBLAS_INCLUDE_DIR. If
      these variables do not exist in your CMake, create them manually. CBLAS_LIBRARY
      and CBLAS_INCLUDE_DIR should be FILEPATH and PATH, respectively, and live in
      /usr/local/Cellar/openblas/ if installed with \"brew install openblas\".")
  endif()

  #option(Gadgetron_BUILD_PYTHON_SUPPORT
  #  "Build Gadgetron Python gadgets (not required for SIRF)" OFF)
  set(Gadgetron_BUILD_PYTHON_SUPPORT OFF) # <-Disabled for v1.0
  set(default_Gadgetron_BUILD_MATLAB_SUPPORT OFF)
  RenameVariable(BUILD_GADGETRON_MATLAB_SUPPORT Gadgetron_BUILD_MATLAB_SUPPORT default_Gadgetron_BUILD_MATLAB_SUPPORT)
  option(Gadgetron_BUILD_MATLAB_SUPPORT
    "Build Gadgetron MATLAB gadgets (not required for SIRF)" ${default_Gadgetron_BUILD_MATLAB_SUPPORT})
  option(Gadgetron_USE_MKL "Instruct Gadgetron to build linking to the MKL. The user must be able to install MKL on his own." OFF)

  option(Gadgetron_USE_CUDA "Enable Gadgetron CUDA (if cuda libraries are present)" ON)
  mark_as_advanced(Gadgetron_USE_CUDA)
  

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
        -DBUILD_PYTHON_SUPPORT=${Gadgetron_BUILD_PYTHON_SUPPORT}
        -DBUILD_MATLAB_SUPPORT=${Gadgetron_BUILD_MATLAB_SUPPORT}
        -DCMAKE_PREFIX_PATH=${SUPERBUILD_INSTALL_DIR}
        -DCMAKE_LIBRARY_PATH=${SUPERBUILD_INSTALL_DIR}/lib
        -DCMAKE_INCLUDE_PATH=${SUPERBUILD_INSTALL_DIR}/include
        -DCMAKE_INSTALL_PREFIX=${Gadgetron_Install_Dir}
        -DBOOST_INCLUDEDIR=${BOOST_ROOT}/include/
        -DBOOST_LIBRARYDIR=${BOOST_LIBRARY_DIR}
        -DPYTHON_EXECUTABLE=${PYTHON_EXECUTABLE}
        -DPYTHON_INCLUDE_DIR=${PYTHON_INCLUDE_DIRS}
        -DPYTHON_LIBRARY=${PYTHON_LIBRARIES}
        -DGTEST_ROOT=${GTEST_ROOT}
        ${HDF5_CMAKE_ARGS}
        -DISMRMRD_DIR=${ISMRMRD_DIR}
	-DUSE_MKL:BOOL=${Gadgetron_USE_MKL}
        -DUSE_CUDA=${Gadgetron_USE_CUDA}
        -DCBLAS_INCLUDE_DIR:PATH=${CBLAS_INCLUDE_DIR}
        -DCBLAS_LIBRARY:FILEPATH=${CBLAS_LIBRARY}

	    INSTALL_DIR ${Gadgetron_Install_Dir}
    DEPENDS
        ${${proj}_DEPENDENCIES}
  )

    set(Gadgetron_ROOT        ${Gadgetron_SOURCE_DIR})
    set(Gadgetron_INCLUDE_DIR ${Gadgetron_SOURCE_DIR})

  # Gadgetron only adds tests if (GTEST_FOUND AND ARMADILLO_FOUND)
  if (BUILD_TESTING_${proj})
    add_test(NAME ${proj}_TESTS
         COMMAND ${CMAKE_CTEST_COMMAND} -C $<CONFIGURATION> --output-on-failure
         WORKING_DIRECTORY ${${proj}_BINARY_DIR}/test)
  endif()
     
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
