#========================================================================
# Author: Edoardo Pasca
# Copyright 2019, 2020 STFC
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


    set(cmd "${${proj}_SOURCE_DIR}/build/linux/configure")
    list(APPEND cmd "CPPFLAGS=-I${SUPERBUILD_INSTALL_DIR}/include -L${SUPERBUILD_INSTALL_DIR}/lib")
    if (${${proj}_USE_CUDA})
      list(APPEND cmd "NVCCFLAGS=-I${SUPERBUILD_INSTALL_DIR}/include -L${SUPERBUILD_INSTALL_DIR}/lib")
      set(ASTRA_BUILD_OPTIONS "--with-cuda=${CUDA_TOOLKIT_ROOT_DIR}")

      #create a configure script
      file(WRITE ${${proj}_SOURCE_DIR}/python_build
"
#! /bin/bash
set -ex

CPPFLAGS=\"-DASTRA_CUDA -DASTRA_PYTHON -I${SUPERBUILD_INSTALL_DIR}/include -L${SUPERBUILD_INSTALL_DIR}/lib -I${${proj}_SOURCE_DIR}/include\" CC=${CMAKE_C_COMPILER} ${PYTHON_EXECUTABLE} builder.py build
")

    else()
      # No CUDA
      message (STATUS "No CUDA found on host, skipping GPU")
      set(ASTRA_BUILD_OPTIONS "")

      #create a configure script
      file(WRITE ${${proj}_SOURCE_DIR}/python_build
"
#! /bin/bash
set -ex

CPPFLAGS=\"-DASTRA_PYTHON -I${SUPERBUILD_INSTALL_DIR}/include -L${SUPERBUILD_INSTALL_DIR}/lib -I${${proj}_SOURCE_DIR}/include\" CC=${CMAKE_C_COMPILER} ${PYTHON_EXECUTABLE} builder.py build
")


    endif()
    ExternalProject_Add(${proj}
        ${${proj}_EP_ARGS}
        ${${proj}_EP_ARGS_GIT}
        ${${proj}_EP_ARGS_DIRS}
        
        # This build is Unix specific
        CONFIGURE_COMMAND
          ${CMAKE_COMMAND} -E chdir ${${proj}_SOURCE_DIR}/build/linux ./autogen.sh

        
        BUILD_COMMAND
        ${CMAKE_COMMAND} -E env ${cmd} ${ASTRA_BUILD_OPTIONS} --prefix=${${proj}_INSTALL_DIR} --with-install-type=prefix --with-python=${PYTHON_EXECUTABLE}
        INSTALL_COMMAND
          ${CMAKE_COMMAND} -E chdir ${${proj}_BINARY_DIR}/ make -j2 install-libraries
        DEPENDS
          ${${proj}_DEPENDENCIES}
      )

    set(python_wrapper "astra-python-wrapper")
    file(COPY ${${proj}_SOURCE_DIR}/python_build
         DESTINATION ${${proj}_BINARY_DIR}/python
         FILE_PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ)

    #create an install script
    file(WRITE ${${proj}_SOURCE_DIR}/python_install
"
#! /bin/bash
set -ex
build_dir=`ls ${${proj}_SOURCE_DIR}/python/build/ | grep lib`
cp -rv ${${proj}_SOURCE_DIR}/python/build/$build_dir/astra ${${proj}_INSTALL_DIR}/python/

")

    file(COPY ${${proj}_SOURCE_DIR}/python_install
 	   DESTINATION ${${proj}_BINARY_DIR}/python
           FILE_PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ)

    ExternalProject_Add(${python_wrapper}
        ${${proj}_EP_ARGS}
        ${${proj}_EP_ARGS_DIRS}
        # INSTALL_DIR ${libastra_Install_Dir}

        CONFIGURE_COMMAND ${CMAKE_COMMAND} -E copy ${${proj}_BINARY_DIR}/python/python_build ${${proj}_SOURCE_DIR}/python/ && ${CMAKE_COMMAND} -E copy ${${proj}_BINARY_DIR}/python/python_install ${${proj}_SOURCE_DIR}/python/

        # This build is Unix specific
        BUILD_COMMAND
          ${CMAKE_COMMAND} -E chdir ${${proj}_SOURCE_DIR}/python ./python_build
        INSTALL_COMMAND
          ${CMAKE_COMMAND} -E chdir ${${proj}_SOURCE_DIR}/python ./python_install
        DEPENDS
          ${proj}
      )

  else()
    # if SETUP_PY one can launch the conda build.sh script setting
    # the appropriate variables.
    message(FATAL_ERROR "Only PYTHONPATH install method is currently supported")
  endif()


  set(${proj}_ROOT        ${${proj}_SOURCE_DIR})
  set(${proj}_INCLUDE_DIR ${${proj}_SOURCE_DIR})
  add_test(NAME ASTRA_BASIC_TEST
           COMMAND ${PYTHON_EXECUTABLE} -c "import astra; astra.test_noCUDA()"
           WORKING_DIRECTORY ${${proj}_SOURCE_DIR})
  if (${${proj}_USE_CUDA})
    add_test(NAME ASTRA_BASIC_GPU_TEST
             COMMAND ${PYTHON_EXECUTABLE} -c "import astra; astra.test_CUDA()"
             WORKING_DIRECTORY ${${proj}_SOURCE_DIR})
  endif()

else()
  ExternalProject_Add_Empty(${proj} DEPENDS "${${proj}_DEPENDENCIES}"
                            ${${proj}_EP_ARGS_DIRS}
                            )
endif()
