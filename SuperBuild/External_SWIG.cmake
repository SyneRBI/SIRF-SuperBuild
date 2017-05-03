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
set(proj SWIG)

# Set dependency list
set(${proj}_DEPENDENCIES "")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here
  
  if (WIN32)
  set(SWIG_Install_Dir ${CMAKE_CURRENT_BINARY_DIR}/INSTALL/SWIG-3.0.12)
  # Just use precompiled version
  set(${proj}_URL http://prdownloads.sourceforge.net/swig/swigwin-3.0.12.zip  )
  set(${proj}_MD5 a49524dad2c91ae1920974e7062bfc93 )

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    URL ${${proj}_URL}
    URL_HASH MD5=${${proj}_MD5}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory ${SWIG_Install_Dir}
        COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> ${SWIG_Install_Dir}
  )
    set( SWIG_EXECUTABLE ${SWIG_Install_Dir}/swig.exe )
  
  return()
  endif(WIN32)

  set(SWIG_Install_Dir ${CMAKE_CURRENT_BINARY_DIR}/INSTALL)
  
  set(SWIG_Configure_Script ${CMAKE_CURRENT_LIST_DIR}/External_SWIG_configure.cmake)
  set(SWIG_Build_Script ${CMAKE_CURRENT_LIST_DIR}/External_SWIG_build.cmake)

  set(${proj}_URL http://prdownloads.sourceforge.net/swig/swig-3.0.12.tar.gz )
  set(${proj}_MD5 82133dfa7bba75ff9ad98a7046be687c )

  if(CMAKE_COMPILER_IS_CLANGXX)
    set(CLANG_ARG -DCMAKE_COMPILER_IS_CLANGXX:BOOL=ON)
  endif()

  set(SWIG_SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj} )

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    URL ${${proj}_URL}
    URL_HASH MD5=${${proj}_MD5}
    SOURCE_DIR ${SWIG_SOURCE_DIR}
    BINARY_DIR ${SWIG_SOURCE_DIR}
    CONFIGURE_COMMAND ./configure --without-pcre --prefix ${SWIG_Install_Dir}
    INSTALL_DIR ${SWIG_Install_Dir}
  )

  set( SWIG_EXECUTABLE ${SWIG_Install_Dir}/bin/swig )
  set( SWIG_VERSION "3.0.12" )


 else()
    if(${USE_SYSTEM_${externalProjName}})
      find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} ${${externalProjName}_COMPONENTS} REQUIRED)
      message(STATUS "USING the system ${externalProjName}, found SWIG_EXECUTABLE=${SWIG_EXECUTABLE}, SWIG_VERSION=${SWIG_VERSION}")
  endif()
  ExternalProject_Add_Empty(${proj} "${${proj}_DEPENDENCIES}")
endif()

mark_as_superbuild(
  VARS
    ${externalProjName}_DIR:PATH
  LABELS
    "FIND_PACKAGE"
)
