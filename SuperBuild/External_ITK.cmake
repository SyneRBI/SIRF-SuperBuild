#========================================================================
# Author: Richard Brown
# Author: Benjamin A Thomas
# Author: Kris Thielemans
# Copyright 2017, 2020, 2022 University College London
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
set(proj ITK)

option(ITK_USE_SYSTEM_HDF5 "ITK to use same HDF5 library as other software (set to OFF if ITK has problems with HDF5)" ON)

# Set dependency list
if (ITK_USE_SYSTEM_HDF5)
  set(${proj}_DEPENDENCIES "HDF5")
endif()

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})

SetCanonicalDirectoryNames(${proj})

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")
  SetGitTagAndRepo("${proj}")

  ### --- Project specific additions here

  option(BUILD_TESTING_${proj} "Build tests for ${proj}" OFF)
  option(ITK_SKIP_PATH_LENGTH_CHECKS "Tell ITK to not check lengths of paths" ON)

  #message(STATUS "HDF5_ROOT in External_SIRF: " ${HDF5_ROOT})
  set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} ${SUPERBUILD_INSTALL_DIR})
  set(CMAKE_INCLUDE_PATH ${CMAKE_INCLUDE_PATH} ${SUPERBUILD_INSTALL_DIR})

  OPTION(ITK_SHARED_LIBS "ITK uses shared libraries" ON)

  OPTION(ITK_MINIMAL_LIBS "Only build ITK IO libraries" ON)
  if (ITK_MINIMAL_LIBS)
    # Currently we only build some of the IO Modules. In fact, we don't even enable all
    # IO modules as this minimises size and compilation time, and also
    # increases chances of success of compilation.
    # For example, ITKIOMINC fails to build with system HDF5 1.10.0 - 1.10.1,
    # while sadly Ubuntu 18.04 comes with HDF 1.10.0.

    # -DModule_ITKReview:BOOL=ON # should be ON for PETPVC, but not for others
    # ITKImageGrid is ON as it contains itkOrientImageFilter, used by STIR
    # ITKGroup_Filtering is ON as used by pet_rd_tools, PETPVC
    set(ITK_CMAKE_FLAGS
      -DITK_BUILD_DEFAULT_MODULES:BOOL=OFF
      -DITKGroup_IO:BOOL=OFF
      -DModule_ITKIOBMP:BOOL=ON
      -DModule_ITKIOGDCM:BOOL=ON
      -DModule_ITKIOGIPL:BOOL=ON
      -DModule_ITKIOJPEG:BOOL=ON
      -DModule_ITKIOJPEG2000:BOOL=ON
      -DModule_ITKIOMeta:BOOL=ON
      -DModule_ITKIONIFTI:BOOL=ON
      -DModule_ITKIONRRD:BOOL=ON
      -DModule_ITKIOPNG:BOOL=ON
      -DModule_ITKIORAW:BOOL=ON
      -DModule_ITKIOTIFF:BOOL=ON
      -DModule_ITKImageGrid:BOOL=ON
      -DITKGroup_Filtering=ON
      )
  else()

    set(ITK_CMAKE_FLAGS
      -DITK_BUILD_DEFAULT_MODULES:BOOL=ON
      )
  endif()

  set(ITK_CMAKE_FLAGS ${ITK_CMAKE_FLAGS}
    -DITK_USE_SYSTEM_HDF5:BOOL=${ITK_USE_SYSTEM_HDF5})
  if (ITK_USE_SYSTEM_HDF5)
    set(ITK_CMAKE_FLAGS ${ITK_CMAKE_FLAGS}
      ${HDF5_CMAKE_ARGS}
      )
  endif()

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    ${${proj}_EP_ARGS_GIT}
    ${${proj}_EP_ARGS_DIRS}

    CMAKE_ARGS
      -DCMAKE_PREFIX_PATH:PATH=${SUPERBUILD_INSTALL_DIR}
      -DCMAKE_LIBRARY_PATH:PATH=${SUPERBUILD_INSTALL_DIR}/lib
      -DCMAKE_INCLUDE_PATH:PATH=${SUPERBUILD_INSTALL_DIR}
      -DCMAKE_INSTALL_PREFIX:PATH=${${proj}_INSTALL_DIR}
	    -DBUILD_SHARED_LIBS:BOOL=${ITK_SHARED_LIBS}
      -DBUILD_TESTING:BOOL=${BUILD_TESTING_${proj}}
      -DBUILD_EXAMPLES:BOOL=OFF
      -DITK_SKIP_PATH_LENGTH_CHECKS:BOOL=${ITK_SKIP_PATH_LENGTH_CHECKS}
      ${ITK_CMAKE_FLAGS}
      ${${proj}_EXTRA_CMAKE_ARGS}
    DEPENDS ${${proj}_DEPENDENCIES}
  )

  set(${proj}_INCLUDE_DIR ${${proj}_SOURCE_DIR})

  if (BUILD_TESTING_${proj})
    add_test(NAME ${proj}_TESTS
         COMMAND ${CMAKE_CTEST_COMMAND} -C $<CONFIGURATION> --output-on-failure
         WORKING_DIRECTORY ${${proj}_BINARY_DIR})
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
