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

  if(CMAKE_COMPILER_IS_CLANGXX)
    set(CLANG_ARG -DCMAKE_COMPILER_IS_CLANGXX:BOOL=ON)
  endif()

if (WIN32)

  # we don't bother building it, but copy the files into an FFTW subdir_directory
  # We then still need to run "lib" to create export libraries (as per the README-WINDOWS from FFTW)
  # TODO: We should check if we're building with 32bit or 64bit tools, assuming the latter
  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    URL ${${proj}_URL}
    URL_HASH MD5=${${proj}_MD5}
    ${${proj}_EP_ARGS_DIRS}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory ${${proj}_INSTALL_DIR}
        COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> ${${proj}_INSTALL_DIR}/FFTW
        COMMAND ${CMAKE_COMMAND} -E chdir ${${proj}_INSTALL_DIR}/FFTW lib /machine:x64 /def:libfftw3f-3.def
        COMMAND ${CMAKE_COMMAND} -E chdir ${${proj}_INSTALL_DIR}/FFTW lib /machine:x64 /def:libfftw3-3.def
        COMMAND ${CMAKE_COMMAND} -E chdir ${${proj}_INSTALL_DIR}/FFTW lib /machine:x64 /def:libfftw3l-3.def
  )
  set( ${proj}_INSTALL_DIR ${${proj}_INSTALL_DIR}/FFTW )
  set(FFTW3_CMAKE_ARGS
      -DFFTW3_INCLUDE_DIR:PATH=${${proj}_INSTALL_DIR}/
	  -DFFTW3F_LIBRARY:FILEPATH=${${proj}_INSTALL_DIR}/libfftw3f-3.lib
	  -DFFTW3_LIBRARY:FILEPATH=${${proj}_INSTALL_DIR}/libfftw3-3.lib
	  )
else()
  #set(FFTW_SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj} )
  
  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    URL ${${proj}_URL}
    URL_HASH MD5=${${proj}_MD5}
    ${${proj}_EP_ARGS_DIRS}
    CONFIGURE_COMMAND ${${proj}_SOURCE_DIR}/configure --enable-float --with-pic --prefix ${${proj}_INSTALL_DIR}
  )
  #set( FFTW3_ROOT_DIR ${${proj}_INSTALL_DIR} )

  # current FindFFTW3.cmake ignores FFTW3_ROOT_DIR https://github.com/CCPPETMR/SIRF-SuperBuild/issues/147
  # let's hope for the best
  # ideally we would also set DFFTW3_LIBRARIES but that's hard and system dependent
  set(FFTW3_CMAKE_ARGS
      -DFFTW3_INCLUDE_DIR:PATH=${${proj}_INSTALL_DIR}/include
  )

endif()


 else()
    if(${USE_SYSTEM_${externalProjName}})
      find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} ${${externalProjName}_COMPONENTS} REQUIRED)
      message(STATUS "USING the system ${externalProjName}, found FFTW3_INCLUDE_DIR=${FFTW3_INCLUDE_DIR}, FFTW3_LIBRARY=${FFTW3_LIBRARY}")
      set(FFTW3_CMAKE_ARGS
         -DFFTW3_INCLUDE_DIR:PATH=${FFTW3_INCLUDE_DIR}
         -DFFTW3_LIBRARIES:FILEPATH=${FFTW3_LIBRARIES}
      )
  endif()
  ExternalProject_Add_Empty(${proj} DEPENDS "${${proj}_DEPENDENCIES}"
    ${${proj}_EP_ARGS_DIRS}
  )
endif()

# Currently, setting FFTW3_ROOT_DIR has no effect, see https://github.com/SyneRBI/SIRF-SuperBuild/issues/147
#mark_as_superbuild(
#  ALL_PROJECTS
#  VARS
#    ${externalProjName}_ROOT_DIR:PATH
#  LABELS
#    "FIND_PACKAGE"
#)

message(STATUS "FFTW3_CMAKE_ARGS=${FFTW3_CMAKE_ARGS}")