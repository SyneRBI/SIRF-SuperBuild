#========================================================================
# Author: Benjamin A Thomas
# Author: Kris Thielemans
# Author: Edoardo Pasca
# Author: Casper da Costa-Luis
# Copyright 2017, 2020 University College London
# Copyright 2017, 2020 STFC
# Copyright 2019, 2020 King's College London
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
set(proj TomoPhantom)

# Set dependency list
set(${proj}_DEPENDENCIES "")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})
SetCanonicalDirectoryNames(${proj})
# Get any flag from the superbuild call that may be particular to this projects CMAKE_ARGS
SetExternalProjectFlags(${proj})

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")
  SetGitTagAndRepo("${proj}")

  ### --- Project specific additions here

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    ${${proj}_EP_ARGS_GIT}
    ${${proj}_EP_ARGS_DIRS}
    

    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX:PATH=${${proj}_INSTALL_DIR}
    	-DLIBRARY_DIR:PATH=${${proj}_INSTALL_DIR}/lib
    	-DINCLUDE_DIR:PATH=${${proj}_INSTALL_DIR}/include
    	-DCONDA_BUILD=OFF
    	-DBUILD_PYTHON_WRAPPER=ON
        ${PYTHONLIBS_CMAKE_ARGS}
    	-DPYTHON_DEST_DIR:PATH=${PYTHON_DEST_DIR}
    	-DPYTHON_STRATEGY=${PYTHON_STRATEGY}
      ${${proj}_EXTRA_CMAKE_ARGS_LIST}
    # TODO this relies on using "make", but we could be build with something else
    #INSTALL_COMMAND make TomoPhantom
    DEPENDS
        ${${proj}_DEPENDENCIES}
  )

   else()
      if(${USE_SYSTEM_${externalProjName}})
        find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} REQUIRED)
        message(STATUS "USING the system ${externalProjName}, found ACE_LIBRARIES=${ACE_LIBRARIES}")
    endif()
  ExternalProject_Add_Empty(${proj} DEPENDS "${${proj}_DEPENDENCIES}"
                            ${${proj}_EP_ARGS_DIRS}
  )
  endif()
