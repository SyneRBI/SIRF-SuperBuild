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
set(${proj}_DEPENDENCIES "Boost;HDF5;ISMRMRD;FFTW3double;googletest;Armadillo")

message(STATUS "MATLAB_ROOT=" ${MATLAB_ROOT})
#message(STATUS "STIR_DIR=" ${STIR_DIR})

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here
  set(Gadgetron_Install_Dir ${CMAKE_CURRENT_BINARY_DIR}/INSTALL)
  set(${proj}_URL https://github.com/gadgetron/gadgetron )

  #message(STATUS "HDF5_ROOT in External_SIRF: " ${HDF5_ROOT})
  set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} ${CMAKE_CURRENT_BINARY_DIR}/INSTALL)
  set(CMAKE_INCLUDE_PATH ${CMAKE_INCLUDE_PATH} ${CMAKE_CURRENT_BINARY_DIR}/INSTALL)

  # work-around Gadgetron problem with old MKL
find_package(MKL)
if (MKL_FOUND)
  if ( MKL_VERSION_STRING VERSION_LESS 11.2.0 )
    message(WARNING "Gadgetron requires Intel MKL version >= 11.2.0 but found ${MKL_VERSION_STRING}. Disabling usage of MKL")
    set(MKL_FOUND false)
    set(MKLROOT_PATH=)
  endif ()
endif ()
  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    GIT_REPOSITORY ${${proj}_URL}
    SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj}

    CMAKE_ARGS
        -DCMAKE_PREFIX_PATH=${CMAKE_CURRENT_BINARY_DIR}/INSTALL
        -DCMAKE_LIBRARY_PATH=${CMAKE_CURRENT_BINARY_DIR}/INSTALL/lib
        -DCMAKE_INCLUDE_PATH=${CMAKE_CURRENT_BINARY_DIR}/INSTALL
        -DCMAKE_INSTALL_PREFIX=${Gadgetron_Install_Dir}
        -DBOOST_INCLUDEDIR=${BOOST_ROOT}/include/
        -DBOOST_LIBRARYDIR=${BOOST_LIBRARY_DIR}
        -DMATLAB_ROOT=${MATLAB_ROOT}
        -DGTEST_ROOT=${GTEST_ROOT}
        -DHDF5_ROOT=${HDF5_ROOT}
        -DHDF5_INCLUDE_DIRS=${HDF5_INCLUDE_DIRS}
        -DHDF5_LIBRARIES=${HDF5_LIBRARIES}
        -DFFTW_ROOT_DIR=${CMAKE_CURRENT_BINARY_DIR}/INSTALL
        -DISMRMRD_DIR=${ISMRMRD_DIR}
        -DMKLROOT_PATH=${MKLROOT_PATH}
	    INSTALL_DIR ${Gadgetron_Install_Dir}
    DEPENDS
        ${${proj}_DEPENDENCIES}
  )

    set(Gadgetron_ROOT        ${Gadgetron_SOURCE_DIR})
    set(Gadgetron_INCLUDE_DIR ${Gadgetron_SOURCE_DIR})

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
