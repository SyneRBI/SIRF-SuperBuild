#========================================================================
# Author: Edoardo Pasca
# Copyright 2019 UKRI STFC
#
# This file is part of the CCP SyneRBI (formerly PETMR) Synergistic Image Reconstruction Framework (SIRF) SuperBuild.
##
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
set(proj astra-toolbox)

# Set dependency list
set(${proj}_DEPENDENCIES "Boost")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

find_package(Cython)
if(NOT ${Cython_FOUND})
    message(FATAL_ERROR "astra-toolkit binding to Python depends on Cython")
endif()

# as in CCPi RGL
option(${proj}_USE_CUDA "Enable ${proj} CUDA (if cuda libraries are present)" ${USE_CUDA})
if (${${proj}_USE_CUDA})
   set (CUDA_TOOLKIT_ROOT_DIR $ENV{CUDA_BIN_DIR})
   set(CUDA_NVCC_FLAGS "-Xcompiler -fPIC -shared -D_FORCE_INLINES")
   message(STATUS "CUDA_SDK_ROOT_DIR ${CUDA_SDK_ROOT_DIR}")
   message(STATUS "CUDA_TOOLKIT_ROOT_DIR ${CUDA_TOOLKIT_ROOT_DIR}")
endif()

# Set external name (same as internal for now)
set(externalProjName ${proj})
SetCanonicalDirectoryNames(${proj})

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")
  SetGitTagAndRepo("${proj}")
  ### --- Project specific additions here
  
  message("astra-toolkit URL " ${${proj}_URL}  )
  message("astra-toolkit TAG " ${${proj}_TAG}  )

  set(cmd "${${proj}_SOURCE_DIR}/build/linux/configure")
  list(APPEND cmd "CPPFLAGS=-I${SUPERBUILD_INSTALL_DIR}/include -L${SUPERBUILD_INSTALL_DIR}/lib")
  if (${${proj}_USE_CUDA})
    list(APPEND cmd "NVCCFLAGS=-I${SUPERBUILD_INSTALL_DIR}/include -L${SUPERBUILD_INSTALL_DIR}/lib")
    set(ASTRA_BUILD_OPTIONS "--with-cuda=${CUDA_TOOLKIT_ROOT_DIR}")
  else()
  set(ASTRA_BUILD_OPTIONS "")
    endif()

  SetGitTagAndRepo("${proj}")
  ExternalProject_Add(${proj}
      ${${proj}_EP_ARGS}
      ${${proj}_EP_ARGS_GIT}
      ${${proj}_EP_ARGS_DIRS}
      

      # This build is Unix specific
      UPDATE_COMMAND ${CMAKE_COMMAND} -E rm -f ${${proj}_SOURCE_DIR}/python/python_build && ${CMAKE_COMMAND} -E rm -f ${${proj}_SOURCE_DIR}/python/python_install
      CONFIGURE_COMMAND
        ${CMAKE_COMMAND} -E chdir ${${proj}_SOURCE_DIR}/build/linux ./autogen.sh
      BUILD_COMMAND
        ${CMAKE_COMMAND} -E env ${cmd} ${ASTRA_BUILD_OPTIONS} --prefix=${${proj}_INSTALL_DIR} --with-install-type=prefix --with-python=${PYTHON_EXECUTABLE}
      INSTALL_COMMAND
        ${CMAKE_COMMAND} -E chdir ${${proj}_BINARY_DIR}/ make -j2 install-libraries
      DEPENDS
        ${${proj}_DEPENDENCIES}
    )

    


  set(${proj}_ROOT        ${${proj}_SOURCE_DIR})
  set(${proj}_INCLUDE_DIR ${${proj}_SOURCE_DIR})

else()
  ExternalProject_Add_Empty(${proj} DEPENDS "${${proj}_DEPENDENCIES}"
                            ${${proj}_EP_ARGS_DIRS}
                            )
endif()
