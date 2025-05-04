#========================================================================
# Author: Benjamin A Thomas
# Author: Edoardo Pasca
# Copyright 2017, 2020, 2022 University College London
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
set(proj GTest)

# Set dependency list
set(${proj}_DEPENDENCIES "")


# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})

SetCanonicalDirectoryNames(${proj})

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")
  SetGitTagAndRepo("${proj}")

  ### --- Project specific additions here

  set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} ${SUPERBUILD_INSTALL_DIR})
  set(CMAKE_INCLUDE_PATH ${CMAKE_INCLUDE_PATH} ${SUPERBUILD_INSTALL_DIR})

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    ${${proj}_EP_ARGS_GIT}
    ${${proj}_EP_ARGS_DIRS}

    CMAKE_ARGS
      -DCMAKE_PREFIX_PATH:PATH=${SUPERBUILD_INSTALL_DIR}
      -DCMAKE_INSTALL_PREFIX:PATH=${${proj}_INSTALL_DIR}
    DEPENDS
        ${${proj}_DEPENDENCIES}
  )

  if (${CMAKE_VERSION} VERSION_LESS "3.20")
    # older CMake versions ignore GTest_DIR
    set(GTest_CMAKE_ARGS
      -DGTEST_ROOT:PATH="${GTest_INSTALL_DIR}")
  else()
    # We're using GTest 1.11.0 or later which exports CMake files
    set(GTest_CMAKE_ARGS
      -DGTest_DIR:PATH="${GTest_INSTALL_DIR}/lib/cmake/GTest")
  endif()

else()
      if(${USE_SYSTEM_${externalProjName}})
        message(STATUS "USING the system ${externalProjName}, set GTest_DIR (or GTEST_ROOT for GTest < 1.8.1) if needed.")
        find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} REQUIRED)
        get_filename_component(GTEST_ROOT ${GTEST_LIBRARIES} DIRECTORY)
    endif()
    ExternalProject_Add_Empty(${proj} DEPENDS "${${proj}_DEPENDENCIES}"
      ${${proj}_EP_ARGS_DIRS})

    if (DEFINED GTest_DIR)
      set(GTest_CMAKE_ARGS -DGTest_DIR:PATH="${GTest_DIR}")
    elseif (DEFINED GTEST_ROOT)
      set(GTest_CMAKE_ARGS -DGTEST_ROOT:PATH="${GTEST_ROOT}")
    endif()
endif()
