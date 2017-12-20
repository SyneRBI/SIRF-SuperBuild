#========================================================================
# Author: Benjamin A Thomas
# Author: Edoardo Pasca
# Copyright 2017 University College London
# Copyright 2017 Science Technology Facilities Council
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
if (WIN32)
 if(NOT "x_${CMAKE_GENERATOR_PLATFORM}" STREQUAL "x_x64")
    message( FATAL_ERROR "The SuperBuild currently has Win64 hard-wired for dependent libraries. Please use a Win64 generator")
 endif()
endif()

set( SOURCE_DOWNLOAD_CACHE ${CMAKE_CURRENT_BINARY_DIR} CACHE PATH
    "The path for downloading external source directories" )

mark_as_advanced( SOURCE_DOWNLOAD_CACHE )

set(externalProjName ${PRIMARY_PROJECT_NAME})
set(proj ${PRIMARY_PROJECT_NAME})

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/INSTALL" CACHE PATH "Prefix for path for installation" FORCE)
endif()

set (SUPERBUILD_INSTALL_DIR ${CMAKE_INSTALL_PREFIX})

include(ExternalProject)

set(EXTERNAL_PROJECT_BUILD_TYPE "Release" CACHE STRING "Default build type for support libraries")
set_property(CACHE EXTERNAL_PROJECT_BUILD_TYPE PROPERTY
STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")

# Make sure that some CMake variables are passed to all dependencies
mark_as_superbuild(
   PROJECTS ALL_PROJECTS
   VARS CMAKE_GENERATOR:STRING CMAKE_GENERATOR_PLATFORM:STRING CMAKE_GENERATOR_TOOLSET:STRING
        CMAKE_C_COMPILER:FILEPATH CMAKE_CXX_COMPILER:FILEPATH
        CMAKE_INSTALL_PREFIX:PATH
)

# Attempt to make Python settings consistent
FIND_PACKAGE(PythonInterp)
if (PYTHONINTERP_FOUND)
 set(Python_ADDITIONAL_VERSIONS ${PYTHON_VERSION_STRING})
  message(STATUS "Found PYTHON_EXECUTABLE=${PYTHON_EXECUTABLE}")
  message(STATUS "Python version ${PYTHON_VERSION_STRING}")
endif()
FIND_PACKAGE(PythonLibs)

set(Matlab_ROOT_DIR $ENV{Matlab_ROOT_DIR} CACHE PATH "Path to Matlab root directory" )

option(USE_SYSTEM_Boost "Build using an external version of Boost" OFF)
option(USE_SYSTEM_STIR "Build using an external version of STIR" OFF)
option(USE_SYSTEM_HDF5 "Build using an external version of HDF5" OFF)
option(USE_SYSTEM_ISMRMRD "Build using an external version of ISMRMRD" OFF)
option(USE_SYSTEM_FFTW3 "Build using an external version of fftw" OFF)
option(USE_SYSTEM_Armadillo "Build using an external version of Armadillo" OFF)
option(USE_SYSTEM_SWIG "Build using an external version of SWIG" OFF)
#option(USE_SYSTEM_Gadgetron "Build using an external version of Gadgetron" OFF)
option(USE_SYSTEM_SIRF "Build using an external version of SIRF" OFF)

if (WIN32)
  set(build_Gadgetron_default OFF)
else()
  set(build_Gadgetron_default ON)
endif()
  
option(BUILD_GADGETRON "Build Gadgetron" ${build_Gadgetron_default})

set(${PRIMARY_PROJECT_NAME}_DEPENDENCIES
    SIRF
)
if (BUILD_GADGETRON)
  list(APPEND ${PRIMARY_PROJECT_NAME}_DEPENDENCIES Gadgetron)
  set(Armadillo_REQUIRED_VERSION 4.600)
endif()

ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${PRIMARY_PROJECT_NAME}_DEPENDENCIES)

message(STATUS "")
message(STATUS "BOOST_ROOT = " ${BOOST_ROOT})
message(STATUS "ISMRMRD_DIR = " ${ISMRMRD_DIR})
message(STATUS "FFTW3_ROOT_DIR = " ${FFTW3_ROOT_DIR})
message(STATUS "STIR_DIR = " ${STIR_DIR})
message(STATUS "HDF5_ROOT = " ${HDF5_ROOT})
message(STATUS "GTEST_ROOT = " ${GTEST_ROOT})
message(STATUS "Matlab_ROOT_DIR = " ${Matlab_ROOT_DIR})
message(STATUS "PYTHON_EXECUTABLE=${PYTHON_EXECUTABLE}")
message(STATUS "PYTHON_LIBRARY=${PYTHON_LIBRARY}")
message(STATUS "PYTHON_INCLUDE_DIR=${PYTHON_INCLUDE_DIR}")

#set(SIRF_Install_Dir ${CMAKE_CURRENT_BINARY_DIR}/SIRF-install)
#set(SIRF_URL https://github.com/CCPPETMR/SIRF )
#message(STATUS "HDF5_ROOT for SIRF: " ${HDF5_ROOT})

#Need to configure main project here.
#set(proj ${PRIMARY_PROJECT_NAME})

#find Matlab and set the binary to the appropriate value
find_package(Matlab MAIN_PROGRAM)

# Make environment files
set(SIRF_SRC_PATH ${SOURCE_DOWNLOAD_CACHE}/SIRF)
set(CCPPETMR_INSTALL ${SUPERBUILD_INSTALL_DIR})
configure_file(env_ccppetmr.sh.in ${CCPPETMR_INSTALL}/bin/env_ccppetmr.sh)
configure_file(env_ccppetmr.csh.in ${CCPPETMR_INSTALL}/bin/env_ccppetmr.csh)


# add tests
enable_testing()
add_test(NAME SIRF_TESTS
	 COMMAND ${CMAKE_CTEST_COMMAND} test WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/SIRF-prefix/src/SIRF-build/)

