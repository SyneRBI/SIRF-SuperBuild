#========================================================================
# Author: Benjamin A Thomas
# Author: Kris Thielemans
# Author: Edoardo Pasca
# Copyright 2017, 2020 University College London
# Copyright 2017, 2020 STFC
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
set(proj Gadgetron)

# Set dependency list
set(${proj}_DEPENDENCIES "Boost;HDF5;ISMRMRD;FFTW3double;Armadillo;GTest;range-v3;JSON;RocksDB;Date")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)


# Set external name (same as internal for now)
set(externalProjName ${proj})

SetCanonicalDirectoryNames(${proj})

# Get any flag from the superbuild call that may be particular to this projects CMAKE_ARGS
SetExternalProjectFlags(${proj})

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")
  SetGitTagAndRepo("${proj}")

  ### --- Project specific additions here

  # Gadgetron only adds tests if (GTEST_FOUND AND ARMADILLO_FOUND)
  # but that's currently always the case.
  # Default to on, as they're quite fast
  option(BUILD_TESTING_${proj} "Build tests for ${proj}" ON)

  # BLAS
  find_package(BLAS)

  message(STATUS "CBLAS ${CBLAS_LIBRARY} ${CBLAS_INCLUDE_DIR}")
  if (NOT (CBLAS_LIBRARY AND CBLAS_INCLUDE_DIR))
    if (APPLE)
      # if the variables don't exist, let the user set them.
      SET(CBLAS_LIBRARY "" CACHE FILEPATH "CBLAS library")
      SET(CBLAS_INCLUDE_DIR "" CACHE PATH "CBLAS include directory")
      message(FATAL_ERROR "Gadgetron needs CBLAS_LIBRARY and CBLAS_INCLUDE_DIR. If
        these variables do not exist in your CMake, create them manually. CBLAS_LIBRARY
        and CBLAS_INCLUDE_DIR should be FILEPATH and PATH, respectively, and live in
        /usr/local/Cellar/openblas/ if installed with \"brew install openblas\".")   
    endif()
  endif()

if (CBLAS_INCLUDE_DIR)
  message(STATUS "Adding CBLAS_INCLUDE_DIR to Gadgetron_CMAKE_ARGS: ${CBLAS_INCLUDE_DIR}")
  list (APPEND ${proj}_CMAKE_ARGS "-DCBLAS_INCLUDE_DIR:PATH=${CBLAS_INCLUDE_DIR}")
else()
  message(STATUS "CBLAS_INCLUDE_DIR will be found (probably) by Gadgetron")
endif()
if (CBLAS_LIBRARY)
  message(STATUS "Adding CBLAS_LIBRARY to Gadgetron_CMAKE_ARGS: ${CBLAS_LIBRARY}")
  list(APPEND ${proj}_CMAKE_ARGS "-DCBLAS_LIBRARY:FILEPATH=${CBLAS_LIBRARY}")
else()
    message(STATUS "CBLAS_LIBRARY will be found (probably) by Gadgetron")
endif()

  #option(Gadgetron_BUILD_PYTHON_SUPPORT
  #  "Build Gadgetron Python gadgets (not required for SIRF)" OFF)
  set(Gadgetron_BUILD_PYTHON_SUPPORT OFF) # <-Disabled for v1.0
  set(default_Gadgetron_BUILD_MATLAB_SUPPORT OFF)
  RenameVariable(BUILD_GADGETRON_MATLAB_SUPPORT Gadgetron_BUILD_MATLAB_SUPPORT default_Gadgetron_BUILD_MATLAB_SUPPORT)
  option(Gadgetron_BUILD_MATLAB_SUPPORT
    "Build Gadgetron MATLAB gadgets (not required for SIRF)" ${default_Gadgetron_BUILD_MATLAB_SUPPORT})
  option(Gadgetron_USE_MKL "Instruct Gadgetron to build linking to the MKL. The user must be able to install MKL on his own." OFF)

  # disable Gadgetron GPU code
  set (${proj}_USE_CUDA OFF)
  # TODO enable after https://github.com/gadgetron/gadgetron/issues/1231
  #if (USE_CUDA)
  #  option(${proj}_USE_CUDA "Enable ${proj} CUDA" ${USE_CUDA})
  #else()
  #  set (${proj}_USE_CUDA OFF)
  #endif()
  
  mark_as_advanced(${proj}_USE_CUDA)

  if (NOT DISABLE_OpenMP)
    option(${proj}_ENABLE_OPENMP "Build ${proj} with OpenMP acceleration" ON)
  else()
    set(${proj}_ENABLE_OPENMP OFF)
  endif()

  # Sets ${proj}_URL_MODIFIED and ${proj}_TAG_MODIFIED
  SetGitTagAndRepo("${proj}")
  set (${proj}_CMAKE_ARGS 
      -DBUILD_PYTHON_SUPPORT:BOOL=${${proj}_BUILD_PYTHON_SUPPORT}
      -DBUILD_MATLAB_SUPPORT:BOOL=${${proj}_BUILD_MATLAB_SUPPORT}
      -DCMAKE_PREFIX_PATH:PATH=${SUPERBUILD_INSTALL_DIR}
      -DCMAKE_INSTALL_PREFIX:PATH=${${proj}_INSTALL_DIR}
      ${Boost_CMAKE_ARGS}
      ${PYTHONLIBS_CMAKE_ARGS}
      ${GTest_CMAKE_ARGS}
      ${HDF5_CMAKE_ARGS}
      ${FFTW3_CMAKE_ARGS}
      -DISMRMRD_DIR:PATH=${ISMRMRD_DIR}
      -DUSE_MKL:BOOL=${${proj}_USE_MKL}
      -DUSE_CUDA:BOOL=${${proj}_USE_CUDA}
      -DUSE_OPENMP:BOOL=${${proj}_ENABLE_OPENMP}
      -DBUILD_TESTING:BOOL=${BUILD_TESTING_${proj}}
      -DBUILD_SUPPRESS_WARNINGS=ON # avoid Gadgetron's conversion of warnings to errors
      )


  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    ${${proj}_EP_ARGS_GIT}
    ${${proj}_EP_ARGS_DIRS}

    CMAKE_ARGS
       ${${proj}_CMAKE_ARGS}
       ${${proj}_EXTRA_CMAKE_ARGS}
    DEPENDS ${${proj}_DEPENDENCIES}
  )

    set(Gadgetron_ROOT        ${Gadgetron_SOURCE_DIR})
    set(Gadgetron_INCLUDE_DIR ${Gadgetron_SOURCE_DIR})

  # Gadgetron only adds tests if (GTEST_FOUND AND ARMADILLO_FOUND)
  if (BUILD_TESTING_${proj})
    if(CMAKE_VERSION VERSION_LESS "3.23") 
       message(WARNING "You need at least CMake 3.23 to build Gadgetron tests. Skipping.")
    else()
      add_test(NAME ${proj}_TESTS
         COMMAND ${CMAKE_CTEST_COMMAND} -C $<CONFIGURATION> --output-on-failure
         WORKING_DIRECTORY ${${proj}_BINARY_DIR}/test)
    endif()
  endif()

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
