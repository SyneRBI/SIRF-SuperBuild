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
#These need to be unique globally
set(proj HDF5)

# Set dependency list
set(${proj}_DEPENDENCIES "")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})

SetCanonicalDirectoryNames(${proj})


if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")
  message(STATUS "HDF5_DOWNLOAD_VERSION=${HDF5_DOWNLOAD_VERSION}")

  ### --- Project specific additions here

  if(CMAKE_COMPILER_IS_CLANGXX)
    set(CLANG_ARG -DCMAKE_COMPILER_IS_CLANGXX:BOOL=ON)
  endif()

  #set(HDF5_SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj}-prefix/src/HDF5/hdf5-1.10.0-patch1 )
  option(${proj}_USE_CUDA "Enable ${proj} CUDA (if cuda libraries are present)" ${USE_CUDA})
  set(HDF5_BUILD_HL_LIB ${${proj}_USE_CUDA})

  if (WIN32 AND (${HDF5_DOWNLOAD_VERSION} STREQUAL 1.8.12))
    find_program(GIT "git")
    set(PATCHFILE "${CMAKE_SOURCE_DIR}/patches/hdf5-${HDF5_DOWNLOAD_VERSION}.patch")
    set(PATCH_COMMAND git apply -v --ignore-space-change --ignore-whitespace ${PATCHFILE})
  else()
    #make it empty, just to be sure
    set(PATCH_COMMAND )
  endif()

  if (PATCH_COMMAND)
    message(STATUS "HDF5 PATCH_COMMAND=${PATCH_COMMAND}")
  endif()

  if (WIN32)
    # It seems that we need shared libraries on Windows, as static ones aren't automatically found
    set(CMAKE_ARGS_WIN -DBUILD_SHARED_LIBS:BOOL=ON)
  endif()

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    URL ${${proj}_URL}
    URL_HASH MD5=${${proj}_MD5}
    PATCH_COMMAND ${PATCH_COMMAND}
    ${${proj}_EP_ARGS_DIRS}

    CMAKE_ARGS
      ${CLANG_ARG}
	  ${CMAKE_ARGS_WIN}
      -DHDF5_BUILD_EXAMPLES:BOOL=OFF
      -DHDF5_BUILD_TOOLS:BOOL=OFF
      -DHDF5_BUILD_HL_LIB:BOOL=${HDF5_BUILD_HL_LIB}
      -DHDF5_BUILD_CPP_LIB:BOOL=ON
      -DBUILD_TESTING:BOOL=OFF
  )

  set( HDF5_ROOT ${HDF5_INSTALL_DIR} )
  set( HDF5_INCLUDE_DIRS ${HDF5_ROOT}/include )
  set(HDF5_CMAKE_ARGS
     -DHDF5_ROOT:PATH=${HDF5_ROOT}
     -DHDF5_INCLUDE_DIRS:PATH=${HDF5_INCLUDE_DIRS}
     -DHDF5_FIND_DEBUG:BOOL=ON
  )

 else()
    if(${USE_SYSTEM_${externalProjName}})
      find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} REQUIRED)
      message(STATUS "USING the system ${externalProjName}, found HDF5_INCLUDE_DIRS=${HDF5_INCLUDE_DIRS}, HDF5_C_LIBRARY_hdf5=${HDF5_C_LIBRARY_hdf5},HDF5_LIBRARIES=${HDF5_LIBRARIES}")
      set(HDF5_CMAKE_ARGS
         -DHDF5_INCLUDE_DIRS:PATH=${HDF5_INCLUDE_DIRS}
         -DHDF5_LIBRARIES:STRING=${HDF5_LIBRARIES}
         -DHDF5_C_LIBRARIES:STRING=${HDF5_C_LIBRARY_hdf5}
         -DHDF5_FIND_DEBUG:BOOL=ON
      )
      if (HDF5_ROOT)
        set(HDF5_CMAKE_ARGS ${HDF5_CMAKE_ARGS} -DHDF5_ROOT:PATH=${HDF5_ROOT})
      endif()
  endif()
  ExternalProject_Add_Empty(${proj} DEPENDS "${${proj}_DEPENDENCIES}"
    ${${proj}_EP_ARGS_DIRS}
  )
endif()

message(STATUS "HDF5_CMAKE_ARGS=${HDF5_CMAKE_ARGS}")
