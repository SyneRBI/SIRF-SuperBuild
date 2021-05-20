#========================================================================
# Author: Edoardo Pasca
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
set(proj CCPi-Regularisation-Toolkit)

# Set dependency list
set(${proj}_DEPENDENCIES "")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

find_package(Cython)
if(NOT ${Cython_FOUND})
    message(FATAL_ERROR "CCPi-Regularisation-Toolkit depends on Cython")
endif()

# Set external name (same as internal for now)
set(externalProjName ${proj})
SetCanonicalDirectoryNames(${proj})
# Get any flag from the superbuild call that may be particular to this projects CMAKE_ARGS
SetExternalProjectFlags(${proj})


if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")
  SetGitTagAndRepo("${proj}")

  ### --- Project specific additions here
  option(${proj}_USE_CUDA "Enable ${proj} CUDA (if cuda libraries are present)" ${USE_CUDA})

  message(STATUS "${proj} URL " ${${proj}_URL}  )
  message(STATUS "${proj} TAG " ${${proj}_TAG}  )
  
  set (CIL_VERSION ${${prog}_TAG})
  # conda build should never get here
  if("${PYTHON_STRATEGY}" STREQUAL "PYTHONPATH")
    # in case of PYTHONPATH it is sufficient to copy the files to the
    # $PYTHONPATH directory
    set (BUILD_PYTHON ${PYTHONLIBS_FOUND})
    if (BUILD_PYTHON)
      set(PYTHON_DEST_DIR "" CACHE PATH "Directory of the CIL regularisation Python modules")
      if (PYTHON_DEST_DIR)
        set(PYTHON_DEST "${PYTHON_DEST_DIR}")
      else()
        set(PYTHON_DEST "${CMAKE_INSTALL_PREFIX}/python")
      endif()
      message(STATUS "Python libraries found")
      message(STATUS "CIL Regularisation Python modules will be installed in " ${PYTHON_DEST})
    endif()
    set(PYTHON_STRATEGY "PYTHONPATH" CACHE STRING "\
      PYTHONPATH: prefix PYTHONPATH \n\
      SETUP_PY:   execute ${PYTHON_EXECUTABLE} setup.py install \n\
      CONDA:      do nothing")
    set_property(CACHE PYTHON_STRATEGY PROPERTY STRINGS PYTHONPATH SETUP_PY CONDA)

    # Sets ${proj}_URL_MODIFIED and ${proj}_TAG_MODIFIED
    
    ExternalProject_Add(${proj}
      ${${proj}_EP_ARGS}
      ${${proj}_EP_ARGS_GIT}
      ${${proj}_EP_ARGS_DIRS}
      # apparently this is the only way to pass environment variables to
      # external projects
      CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env CIL_VERSION=${${proj}_TAG} ${CMAKE_COMMAND} ${${proj}_SOURCE_DIR}
        -DCMAKE_INSTALL_PREFIX:PATH=${${proj}_INSTALL_DIR}
        -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
        -DBUILD_PYTHON_WRAPPER:BOOL=ON
        -DBUILD_CUDA:BOOL=${${proj}_USE_CUDA} -DCONDA_BUILD:BOOL=OFF
        ${PYTHONLIBS_CMAKE_ARGS}
        -DPYTHON_DEST_DIR:PATH=${PYTHON_DEST}

      BUILD_COMMAND ${CMAKE_COMMAND} -E env CIL_VERSION=${${proj}_TAG} ${CMAKE_COMMAND} --build .
      INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
      #TEST_COMMAND ${PYTHON_EXECUTABLE} -m unittest discover -s ${${proj}_SOURCE_DIR}/test/ -p test*.py
      DEPENDS
        ${${proj}_DEPENDENCIES}
    )

    else()
      # if SETUP_PY one can launch the conda build.sh script setting
      # the appropriate variables.
      ExternalProject_Add(${proj}
        ${${proj}_EP_ARGS}
        ${${proj}_EP_ARGS_GIT}
        ${${proj}_EP_ARGS_DIRS}
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""
        INSTALL_COMMAND ${CMAKE_COMMAND} -E env CIL_VERSION=${${proj}_TAG} SRC_DIR=${${proj}_BINARY_DIR} RECIPE_DIR=${${proj}_SOURCE_DIR}/Wrappers/Python/conda-recipe PYTHON=${PYTHON_EXECUTABLE} bash ${${proj}_SOURCE_DIR}/Wrappers/Python/conda-recipe/build.sh
        CMAKE_ARGS
           -DCMAKE_INSTALL_PREFIX:PATH=${${proj}_INSTALL_DIR}
        DEPENDS
           ${${proj}_DEPENDENCIES}
      )
    endif()


    set(${proj}_ROOT        ${${proj}_SOURCE_DIR})
    set(${proj}_INCLUDE_DIR ${${proj}_SOURCE_DIR})
    add_test(NAME CIL_REGULARISATION_TEST_1
             COMMAND ${PYTHON_EXECUTABLE} -m unittest discover -s test -p test_*.py
    WORKING_DIRECTORY ${${proj}_SOURCE_DIR})

  else()
    if(${USE_SYSTEM_${externalProjName}})
      find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} REQUIRED)
      message("USING the system ${externalProjName}")
    endif()
    ExternalProject_Add_Empty(${proj} DEPENDS "${${proj}_DEPENDENCIES}"
                              ${${proj}_EP_ARGS_DIRS}
    )
  endif()

  mark_as_superbuild(
    VARS ""
    LABELS "FIND_PACKAGE"
  )
