#========================================================================
# Author: Benjamin A Thomas
# Author: Kris Thielemans
# Copyright 2017, 2020-2024 University College London
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
set(proj SIRF)

# Set external name (same as internal for now)
set(externalProjName ${proj})

SetCanonicalDirectoryNames(${proj})

# Get any flag from the superbuild call that may be particular to this projects CMAKE_ARGS
SetExternalProjectFlags(${proj})


if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here

  # Set dependency list
  set(${proj}_DEPENDENCIES "Boost;HDF5;ISMRMRD;FFTW3;SWIG")

  option(SIRF_DISABLE_Gadgetron_toolboxes "Disable use of Gadgetron toolboxes for NUFFT etc" OFF)    
  mark_as_advanced(SIRF_DISABLE_Gadgetron_toolboxes)

  if (BUILD_Gadgetron AND NOT SIRF_DISABLE_Gadgetron_toolboxes)
    set(${proj}_DEPENDENCIES "${${proj}_DEPENDENCIES};Gadgetron")
  endif()
  if (BUILD_NIFTYREG)
    set(${proj}_DEPENDENCIES "${${proj}_DEPENDENCIES};NIFTYREG")
  endif()
  if (BUILD_STIR)
    set(${proj}_DEPENDENCIES "${${proj}_DEPENDENCIES};STIR")
  endif()
  if (BUILD_SPM)
    set(${proj}_DEPENDENCIES "${${proj}_DEPENDENCIES};SPM")
  endif()

  # Include dependent projects if any
  ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

  option(BUILD_TESTING_${proj} "Build tests for ${proj}" ON)

  message(STATUS "HDF5_ROOT in External_SIRF: " ${HDF5_ROOT})
  set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} ${SUPERBUILD_INSTALL_DIR})

  if (WIN32)
    set(extra_args "-DSIRF_INSTALL_DEPENDENCIES:BOOL=ON")
  else()
    set(extra_args "")
  endif()

  if (BUILD_SPM)
    set(extra_args ${extra_args} "-DSPM_DIR:PATH=${SPM_DIR}")
  endif()

  if (SIRF_DISABLE_Gadgetron_toolboxes)
    set(extra_args ${extra_args} "-DDISABLE_Gadgetron_toolboxes:BOOL=ON")
  endif()

  # Sets ${proj}_URL_MODIFIED and ${proj}_TAG_MODIFIED
  SetGitTagAndRepo("${proj}")

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    ${${proj}_EP_ARGS_GIT}
    ${${proj}_EP_ARGS_DIRS}

    CMAKE_ARGS
      -DCMAKE_PREFIX_PATH:PATH=${SUPERBUILD_INSTALL_DIR}
      -DCMAKE_LIBRARY_PATH:PATH=${SUPERBUILD_INSTALL_DIR}/lib
      ${Boost_CMAKE_ARGS}
      -DDISABLE_Matlab:BOOL=${DISABLE_Matlab}
      -DMatlab_ROOT_DIR:PATH=${Matlab_ROOT_DIR}
      -DMATLAB_ROOT:PATH=${Matlab_ROOT_DIR} # pass this for compatibility with old SIRF
      -DMATLAB_DEST_DIR:PATH=${MATLAB_DEST_DIR}
      ${STIR_CMAKE_ARGS}
      ${HDF5_CMAKE_ARGS}
      ${FFTW3_CMAKE_ARGS}
      -DISMRMRD_DIR:PATH=${ISMRMRD_DIR}
      -DSWIG_EXECUTABLE:FILEPATH=${SWIG_EXECUTABLE}
      -DDISABLE_PYTHON:BOOL=${DISABLE_PYTHON}
      ${PYTHONLIBS_CMAKE_ARGS}
      -DPYTHON_DEST_DIR:PATH=${PYTHON_DEST}
      -DPYTHON_STRATEGY=${PYTHON_STRATEGY}
      -DNIFTYREG_DIR:PATH=${NIFTYREG_DIR}
      -DREG_ENABLE:BOOL=${BUILD_SIRF_Registration}
		  ${extra_args}
      -DGadgetron_USE_CUDA=${Gadgetron_USE_CUDA}
      ${${proj}_EXTRA_CMAKE_ARGS}
    DEPENDS
        ${${proj}_DEPENDENCIES}
  )

  #if (BUILD_TESTING_${proj})
    add_test(NAME ${proj}_TESTS
         COMMAND ${CMAKE_CTEST_COMMAND} -C $<CONFIGURATION> --output-on-failure
         WORKING_DIRECTORY ${${proj}_BINARY_DIR})
  #endif()

   else()
      if(${USE_SYSTEM_${externalProjName}})
        find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} REQUIRED CONFIG)
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
