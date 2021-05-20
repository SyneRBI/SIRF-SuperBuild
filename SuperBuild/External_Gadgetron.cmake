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
set(${proj}_DEPENDENCIES "ACE;Boost;HDF5;ISMRMRD;FFTW3double;Armadillo;GTest")

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
  # Default to on, as we cannot disable it, and they're quite fast
  option(BUILD_TESTING_${proj} "Build tests for ${proj}" ON)

  #message(STATUS "HDF5_ROOT in External_SIRF: " ${HDF5_ROOT})
  set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} ${SUPERBUILD_INSTALL_DIR})
  set(CMAKE_INCLUDE_PATH ${CMAKE_INCLUDE_PATH} ${SUPERBUILD_INSTALL_DIR})

  # BLAS
  find_package(BLAS)
  if (APPLE AND NOT (CBLAS_LIBRARY AND CBLAS_INCLUDE_DIR))
	# if the variables don't exist, let the user set them.
	SET(CBLAS_LIBRARY "" CACHE FILEPATH "CBLAS library")
	SET(CBLAS_INCLUDE_DIR "" CACHE PATH "CBLAS include directory")
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

  option(${proj}_USE_CUDA "Enable ${proj} CUDA (if cuda libraries are present)" ${USE_CUDA})
  mark_as_advanced(${proj}_USE_CUDA)

  if (NOT DISABLE_OpenMP)
    option(${proj}_ENABLE_OPENMP "Build ${proj} with OpenMP acceleration" ON)
  else()
    set(${proj}_ENABLE_OPENMP OFF)
  endif()

  # require to have access to Python for patching
  if (NOT PYTHON_EXECUTABLE)
    if (${CMAKE_VERSION} VERSION_LESS "3.12")
      find_package(PythonInterp REQUIRED)
    else()
      find_package(Python COMPONENTS Interpreter REQUIRED)
      set (PYTHON_EXECUTABLE ${Python_EXECUTABLE})
    endif()
  endif()

  # Sets ${proj}_URL_MODIFIED and ${proj}_TAG_MODIFIED
  SetGitTagAndRepo("${proj}")

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    ${${proj}_EP_ARGS_GIT}
    ${${proj}_EP_ARGS_DIRS}

    CMAKE_ARGS
      -DBUILD_PYTHON_SUPPORT:BOOL=${Gadgetron_BUILD_PYTHON_SUPPORT}
      -DBUILD_MATLAB_SUPPORT:BOOL=${Gadgetron_BUILD_MATLAB_SUPPORT}
      -DCMAKE_PREFIX_PATH:PATH=${SUPERBUILD_INSTALL_DIR}
      -DCMAKE_LIBRARY_PATH:PATH=${SUPERBUILD_INSTALL_DIR}/lib
      -DCMAKE_INCLUDE_PATH:PATH=${SUPERBUILD_INSTALL_DIR}/include
      -DCMAKE_INSTALL_PREFIX:PATH=${Gadgetron_INSTALL_DIR}
      ${Boost_CMAKE_ARGS}
      ${PYTHONLIBS_CMAKE_ARGS}
      -DGTEST_ROOT:PATH=${GTEST_ROOT}
      ${HDF5_CMAKE_ARGS}
      ${FFTW3_CMAKE_ARGS}
      -DISMRMRD_DIR:PATH=${ISMRMRD_DIR}
      -DUSE_MKL:BOOL=${Gadgetron_USE_MKL}
      -DUSE_CUDA:BOOL=${${proj}_USE_CUDA}
      -DCBLAS_INCLUDE_DIR:PATH=${CBLAS_INCLUDE_DIR}
      -DCBLAS_LIBRARY:FILEPATH=${CBLAS_LIBRARY}
      -DUSE_OPENMP:BOOL=${${proj}_ENABLE_OPENMP}
    DEPENDS
        ${${proj}_DEPENDENCIES}
    INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install 
    COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_SOURCE_DIR}/patches/Gadgetron_include-patch.py ${SUPERBUILD_INSTALL_DIR}/include/gadgetron/hoNFFT.h ${SUPERBUILD_INSTALL_DIR}/include/gadgetron/hoNFFT.h
    COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_SOURCE_DIR}/patches/copy_file_if_not_exists.py ${SUPERBUILD_INSTALL_DIR}/share/gadgetron/config/gadgetron.xml.example ${SUPERBUILD_INSTALL_DIR}/share/gadgetron/config/gadgetron.xml
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
    ${${proj}_EP_ARGS_DIRS}
  )
  endif()

  mark_as_superbuild(
    VARS
      ${externalProjName}_DIR:PATH
    LABELS
      "FIND_PACKAGE"
  )
