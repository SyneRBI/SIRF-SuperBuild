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
set(proj FFTW3double)
set(proj_COMPONENTS "COMPONENTS double")
# Set dependency list
if (WIN32)
  # rely on the "single" version to install everything
  set(${proj}_DEPENDENCIES "FFTW3")
endif()

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})

SetCanonicalDirectoryNames(${proj})

# use FFTW variable
if(NOT ( DEFINED "USE_SYSTEM_FFTW3" AND "${USE_SYSTEM_FFTW3}" ) )
  if (WIN32)
    # don't do anything
    ExternalProject_Add_Empty(${proj})
    return()
  endif()
    
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here

  if(CMAKE_COMPILER_IS_CLANGXX)
    set(CLANG_ARG -DCMAKE_COMPILER_IS_CLANGXX:BOOL=ON)
  endif()

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    URL ${${proj}_URL}
    URL_MD5 ${${proj}_MD5}
    ${${proj}_EP_ARGS_DIRS}
    CONFIGURE_COMMAND ${${proj}_SOURCE_DIR}/configure --with-pic --prefix ${${proj}_INSTALL_DIR}
    INSTALL_DIR ${${proj}_INSTALL_DIR}
  )

 else()
    if(${USE_SYSTEM_${externalProjName}})
      find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} ${${externalProjName}_COMPONENTS} REQUIRED)
      message(STATUS "USING the system ${externalProjName}, found FFTW3double_INCLUDE_DIR=${FFTW3double_INCLUDE_DIR}, FFTW3double_LIBRARY=${FFTW3double_LIBRARY}")
  endif()
  ExternalProject_Add_Empty(${proj} DEPENDS "${${proj}_DEPENDENCIES}"
    ${${proj}_EP_ARGS_DIRS}
)
endif()

# Currently, setting FFTW3_ROOT_DIR has no effect, see https://github.com/SyneRBI/SIRF-SuperBuild/issues/147
#mark_as_superbuild(
#  ALL_PROJECTS
#  VARS
#    FFTW3_ROOT_DIR:PATH
#  LABELS
#    "FIND_PACKAGE"
#)
