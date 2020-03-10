#========================================================================
# Author: Benjamin A Thomas
# Author: Kris Thielemans
# Author: Edoardo Pasca
# Copyright 2017, 2018 University College London
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

#This needs to be unique globally
set(proj FFTW3)
set(proj_COMPONENTS "COMPONENTS single")
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

  set(FFTW_Configure_Script ${CMAKE_CURRENT_LIST_DIR}/External_FFTW_configure.cmake)
  set(FFTW_Build_Script ${CMAKE_CURRENT_LIST_DIR}/External_FFTW_build.cmake)

  if(CMAKE_COMPILER_IS_CLANGXX)
    set(CLANG_ARG -DCMAKE_COMPILER_IS_CLANGXX:BOOL=ON)
  endif()

if (WIN32)
  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    URL ${${proj}_URL}
    URL_HASH MD5=${${proj}_MD5}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory ${${proj}_INSTALL_DIR}
        COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> ${${proj}_INSTALL_DIR}/FFTW
  )
  set( FFTW3_ROOT_DIR ${${proj}_INSTALL_DIR}/FFTW )
else()
  #set(FFTW_SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj} )
  
  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    URL ${${proj}_URL}
    URL_HASH MD5=${${proj}_MD5}
    ${${proj}_EP_ARGS_DIRS}
    CONFIGURE_COMMAND ${${proj}_SOURCE_DIR}/configure --enable-float --with-pic --prefix ${${proj}_INSTALL_DIR}
  )
  set( FFTW3_ROOT_DIR ${${proj}_INSTALL_DIR} )
endif()


 else()
    if(${USE_SYSTEM_${externalProjName}})
      find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} ${${externalProjName}_COMPONENTS} REQUIRED)
      message(STATUS "USING the system ${externalProjName}, found FFTW3_INCLUDE_DIR=${FFTW3_INCLUDE_DIR}, FFTW3_LIBRARY=${FFTW3_LIBRARY}")
  endif()
  ExternalProject_Add_Empty(${proj} DEPENDS "${${proj}_DEPENDENCIES}"
    ${${proj}_EP_ARGS_DIRS}
  )
endif()

# Currently, setting FFTW3_ROOT_DIR has no effect, see https://github.com/CCPPETMR/SIRF-SuperBuild/issues/147
#mark_as_superbuild(
#  ALL_PROJECTS
#  VARS
#    ${externalProjName}_ROOT_DIR:PATH
#  LABELS
#    "FIND_PACKAGE"
#)
