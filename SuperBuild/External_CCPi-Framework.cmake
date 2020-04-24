#========================================================================
# Author: Edoardo Pasca
# Copyright 2018, 2020 STFC
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
set(proj CCPi-Framework)

# Set dependency list
set(${proj}_DEPENDENCIES "")

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
  set(libcilreg_Install_Dir ${SUPERBUILD_INSTALL_DIR})

  set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} ${SUPERBUILD_INSTALL_DIR})
  set(CMAKE_INCLUDE_PATH ${CMAKE_INCLUDE_PATH} ${SUPERBUILD_INSTALL_DIR})

  message("${proj} URL " ${${proj}_URL}  ) 
  message("${proj} TAG " ${${proj}_TAG}  ) 

  if (DISABLE_OpenMP)
    message(FATAL_ERROR "CCPi-Framework requries OpenMP")
  endif()

  # Sets ${proj}_URL_MODIFIED and ${proj}_TAG_MODIFIED
  SetGitTagAndRepo("${proj}")

  # conda build should never get here
  if("${PYTHON_STRATEGY}" STREQUAL "PYTHONPATH")
    # in case of PYTHONPATH it is sufficient to copy the files to the 
    # $PYTHONPATH directory
    ExternalProject_Add(${proj}
      ${${proj}_EP_ARGS}
      ${${proj}_EP_ARGS_GIT}
      SOURCE_DIR ${${proj}_SOURCE_DIR}
      BINARY_DIR ${${proj}_BINARY_DIR}
      DOWNLOAD_DIR ${${proj}_DOWNLOAD_DIR}
      STAMP_DIR ${${proj}_STAMP_DIR}
      TMP_DIR ${${proj}_TMP_DIR}
      INSTALL_DIR ${libcilreg_Install_Dir}
      # apparently this is the only way to pass environment variables to
      # external projects
      CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env CIL_VERSION=${${proj}_TAG}
        ${CMAKE_COMMAND} ${${proj}_SOURCE_DIR}
          -DCMAKE_INSTALL_PREFIX:STRING=${libcilreg_Install_Dir}
          -DCMAKE_BUILD_TYPE:STRING=Release
          -DPYTHON_EXECUTABLE:FILEPATH=${PYTHON_EXECUTABLE}
          -DPYTHON_INCLUDE_DIR:PATH=${PYTHON_INCLUDE_DIRS}
          -DPYTHON_LIBRARY:FILEPATH=${PYTHON_LIBRARIES}      
          -DPYTHON_DEST_DIR:PATH=${PYTHON_DEST}
          -DOPENMP_INCLUDES:PATH=${OPENMP_INCLUDES}
          -DCIL_VERSION:STRING=${${proj}_TAG}
      # INSTALL_COMMAND ${CMAKE_COMMAND} -E env CIL_VERSION=${${proj}_TAG} ${CMAKE_COMMAND} --build . --target install && ${CMAKE_COMMAND} -E copy_directory ${${proj}_SOURCE_DIR}/Wrappers/Python/data ${SUPERBUILD_INSTALL_DIR}/share/ccpi/ && ${PYTHON_EXECUTABLE} ${CMAKE_SOURCE_DIR}/patches/cil-patch.py ${${proj}_SOURCE_DIR}/Wrappers/Python/ccpi/framework/TestData.py ${PYTHON_DEST}/ccpi/framework/TestData.py
      INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install && ${CMAKE_COMMAND} -E copy_directory ${${proj}_SOURCE_DIR}/Wrappers/Python/data ${SUPERBUILD_INSTALL_DIR}/share/ccpi/ && ${PYTHON_EXECUTABLE} ${CMAKE_SOURCE_DIR}/patches/cil-patch.py ${${proj}_SOURCE_DIR}/Wrappers/Python/ccpi/framework/TestData.py ${PYTHON_DEST}/ccpi/framework/TestData.py
      DEPENDS ${${proj}_DEPENDENCIES}
    )

  else()
    # if SETUP_PY one can launch the conda build.sh script setting 
    # the appropriate variables.
    message(FATAL_ERROR "Only PYTHONPATH install method is currently supported")
  endif()


  set(${proj}_ROOT        ${${proj}_SOURCE_DIR})
  set(${proj}_INCLUDE_DIR ${${proj}_SOURCE_DIR})

  add_test(NAME CIL_FRAMEWORK_TESTS_1
           COMMAND ${PYTHON_EXECUTABLE} -m unittest discover -p test_Data*.py 
           WORKING_DIRECTORY ${${proj}_SOURCE_DIR}/Wrappers/Python/test)
  add_test(NAME CIL_FRAMEWORK_TESTS_2
           COMMAND ${PYTHON_EXECUTABLE} -m unittest discover -p test_algor*.p 
           WORKING_DIRECTORY ${${proj}_SOURCE_DIR}/Wrappers/Python/test)
  add_test(NAME CIL_FRAMEWORK_TESTS_3
           COMMAND ${PYTHON_EXECUTABLE} -m unittest discover -p test_run_*.py
           WORKING_DIRECTORY ${${proj}_SOURCE_DIR}/Wrappers/Python/test)
     
  else()
    ExternalProject_Add_Empty(${proj} DEPENDS "${${proj}_DEPENDENCIES}"
      SOURCE_DIR ${${proj}_SOURCE_DIR}
      BINARY_DIR ${${proj}_BINARY_DIR}
      DOWNLOAD_DIR ${${proj}_DOWNLOAD_DIR}
      STAMP_DIR ${${proj}_STAMP_DIR}
      TMP_DIR ${${proj}_TMP_DIR}
    )
  endif()
