#========================================================================
# Author: Edoardo Pasca
# Copyright 2018 UKRI STFC
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
set(proj CIL)

# Set dependency list
set(${proj}_DEPENDENCIES "")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})
SetCanonicalDirectoryNames(${proj})

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here

  if (DISABLE_OpenMP)
    message(FATAL_ERROR "CCPi-Framework requries OpenMP")
  endif()

  # Sets ${proj}_URL_MODIFIED and ${proj}_TAG_MODIFIED
  SetGitTagAndRepo("${proj}")

  if (IPP_ROOT)
    set(DIPP_ROOT "-Ccmake.define.IPP_ROOT=${IPP_ROOT}")
  endif()

  # conda build should never get here
  if("${PYTHON_STRATEGY}" STREQUAL "PYTHONPATH")
    # in case of PYTHONPATH it is sufficient to copy the files to the
    # $PYTHONPATH directory

    # Set _config for use in BUILD_COMMAND etc
    if (NOT CMAKE_BUILD_TYPE)
       # default to Release
       # TODO could add a loop over all CONFIGURATION_TYPES
       set(_config Release)
    else()
       set(_config ${CMAKE_BUILD_TYPE})
    endif()

    ExternalProject_Add(${proj}
      ${${proj}_EP_ARGS}
      ${${proj}_EP_ARGS_GIT}
      ${${proj}_EP_ARGS_DIRS}
      # apparently this is the only way to pass environment variables to
      # external projects
      PATCH_COMMAND ${Python_EXECUTABLE} ${CMAKE_SOURCE_DIR}/patches/cil-patch.py ${${proj}_SOURCE_DIR}/Wrappers/Python/cil/utilities/dataexample.py
      UPDATE_COMMAND ""
      CONFIGURE_COMMAND ""
      BUILD_COMMAND ""
      INSTALL_COMMAND ${CMAKE_COMMAND} -E env ${Python_EXECUTABLE} -m pip install ${${proj}_SOURCE_DIR} ${DIPP_ROOT} -Ccmake.build-type=${config} -Ccmake.args="-G ${CMAKE_GENERATOR}"
        && ${CMAKE_COMMAND} -E copy_directory ${${proj}_SOURCE_DIR}/Wrappers/Python/data ${SUPERBUILD_INSTALL_DIR}/share/cil/
      DEPENDS ${${proj}_DEPENDENCIES}
    )

  else()
    # if SETUP_PY one can launch the conda build.sh script setting
    # the appropriate variables.
    message(FATAL_ERROR "Only PYTHONPATH install method is currently supported. Got ${PYTHON_STRATEGY}")
  endif()


  set(${proj}_ROOT        ${${proj}_SOURCE_DIR})
  set(${proj}_INCLUDE_DIR ${${proj}_SOURCE_DIR})

  add_test(NAME CIL_FRAMEWORK_TESTS_1
           COMMAND ${Python_EXECUTABLE} -m unittest discover -p test_DataContainer.py
           WORKING_DIRECTORY ${${proj}_SOURCE_DIR}/Wrappers/Python/test)
  add_test(NAME CIL_FRAMEWORK_TESTS_2
           COMMAND ${Python_EXECUTABLE} -m unittest discover -p test_algor*.py
           WORKING_DIRECTORY ${${proj}_SOURCE_DIR}/Wrappers/Python/test)
  add_test(NAME CIL_FRAMEWORK_TESTS_3
           COMMAND ${Python_EXECUTABLE} -m unittest discover -p test_run_*.py
           WORKING_DIRECTORY ${${proj}_SOURCE_DIR}/Wrappers/Python/test)
  add_test(NAME CIL_SIRF_TESTS
           COMMAND ${Python_EXECUTABLE} -m unittest discover -p test_SIRF*.py
          WORKING_DIRECTORY ${${proj}_SOURCE_DIR}/Wrappers/Python/test)
  add_test(NAME CIL_FRAMEWORK_TESTS_4
           COMMAND ${Python_EXECUTABLE} -m unittest discover -p test_Block_*.py
           WORKING_DIRECTORY ${${proj}_SOURCE_DIR}/Wrappers/Python/test)
  add_test(NAME CIL_FRAMEWORK_TESTS_5
           COMMAND ${Python_EXECUTABLE} -m unittest discover -p test_dataexample.py
           WORKING_DIRECTORY ${${proj}_SOURCE_DIR}/Wrappers/Python/test)
  add_test(NAME CIL_FRAMEWORK_TESTS_6
           COMMAND ${Python_EXECUTABLE} -m unittest discover -p test_functions.py
           WORKING_DIRECTORY ${${proj}_SOURCE_DIR}/Wrappers/Python/test)
  add_test(NAME CIL_FRAMEWORK_TESTS_7
           COMMAND ${Python_EXECUTABLE} -m unittest discover -p test_Gradient.py
           WORKING_DIRECTORY ${${proj}_SOURCE_DIR}/Wrappers/Python/test)
  add_test(NAME CIL_FRAMEWORK_TESTS_8
           COMMAND ${Python_EXECUTABLE} -m unittest discover -p test_NexusReaderWriter.py
           WORKING_DIRECTORY ${${proj}_SOURCE_DIR}/Wrappers/Python/test)
  add_test(NAME CIL_FRAMEWORK_TESTS_9
           COMMAND ${Python_EXECUTABLE} -m unittest discover -p test_Operator.py
           WORKING_DIRECTORY ${${proj}_SOURCE_DIR}/Wrappers/Python/test)
  add_test(NAME CIL_FRAMEWORK_TESTS_10
           COMMAND ${Python_EXECUTABLE} -m unittest discover -p test_PluginsRegularisation.py
           WORKING_DIRECTORY ${${proj}_SOURCE_DIR}/Wrappers/Python/test)
  add_test(NAME CIL_FRAMEWORK_TESTS_11
           COMMAND ${Python_EXECUTABLE} -m unittest discover -p test_quality_measures.py
           WORKING_DIRECTORY ${${proj}_SOURCE_DIR}/Wrappers/Python/test)
  add_test(NAME CIL_FRAMEWORK_TESTS_12
           COMMAND ${Python_EXECUTABLE} -m unittest discover -p test_smoothMixedL21Norm.py
           WORKING_DIRECTORY ${${proj}_SOURCE_DIR}/Wrappers/Python/test)
  add_test(NAME CIL_FRAMEWORK_TESTS_13
           COMMAND ${Python_EXECUTABLE} -m unittest discover -p test_subset.py
           WORKING_DIRECTORY ${${proj}_SOURCE_DIR}/Wrappers/Python/test)
  add_test(NAME CIL_FRAMEWORK_TESTS_14
           COMMAND ${Python_EXECUTABLE} -m unittest discover -p test_SumFunction.py
           WORKING_DIRECTORY ${${proj}_SOURCE_DIR}/Wrappers/Python/test)
  add_test(NAME CIL_FRAMEWORK_TESTS_15
           COMMAND ${Python_EXECUTABLE} -m unittest discover -p test_TranslateFunction.py
           WORKING_DIRECTORY ${${proj}_SOURCE_DIR}/Wrappers/Python/test)

  # add_test(NAME CIL_FRAMEWORK_TESTS_ALL
  #          COMMAND ${Python_EXECUTABLE} -m unittest discover
  #          WORKING_DIRECTORY ${${proj}_SOURCE_DIR}/Wrappers/Python/test)
  else()
    ExternalProject_Add_Empty(${proj} DEPENDS "${${proj}_DEPENDENCIES}"
      SOURCE_DIR ${${proj}_SOURCE_DIR}
      BINARY_DIR ${${proj}_BINARY_DIR}
      DOWNLOAD_DIR ${${proj}_DOWNLOAD_DIR}
      STAMP_DIR ${${proj}_STAMP_DIR}
      TMP_DIR ${${proj}_TMP_DIR}
    )
  endif()
