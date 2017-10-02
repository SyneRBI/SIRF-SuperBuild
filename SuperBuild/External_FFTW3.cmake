#========================================================================
# Author: Benjamin A Thomas
# Author: Kris Thielemans
# Copyright 2017 University College London
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

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here
  set(FFTW_Install_Dir ${SUPERBUILD_INSTALL_DIR})
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
    INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory ${FFTW_Install_Dir}
        COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> ${FFTW_Install_Dir}/FFTW
  )
  set( FFTW3_ROOT_DIR ${FFTW_Install_Dir}/FFTW )
else()
  set(FFTW_SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj} )
  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    URL ${${proj}_URL}
    URL_HASH MD5=${${proj}_MD5}
    SOURCE_DIR ${FFTW_SOURCE_DIR}
    BINARY_DIR ${FFTW_SOURCE_DIR}
    CONFIGURE_COMMAND ./configure --enable-float --with-pic --prefix ${FFTW_Install_Dir}
    INSTALL_DIR ${FFTW_Install_Dir}
  )
  set( FFTW3_ROOT_DIR ${FFTW_Install_Dir} )
endif()


 else()
    if(${USE_SYSTEM_${externalProjName}})
      find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} ${${externalProjName}_COMPONENTS} REQUIRED)
      message(STATUS "USING the system ${externalProjName}, found FFTW3_INCLUDE_DIR=${FFTW3_INCLUDE_DIR}, FFTW3_LIBRARY=${FFTW3_LIBRARY}")
  endif()
  ExternalProject_Add_Empty(${proj} DEPENDS "${${proj}_DEPENDENCIES}")
endif()

mark_as_superbuild(
  VARS
    ${externalProjName}_DIR:PATH
  LABELS
    "FIND_PACKAGE"
)
