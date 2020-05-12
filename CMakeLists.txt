#========================================================================
# Author: Benjamin A Thomas
# Author: Kris Thielemans
# Copyright 2017, 2020 University College London
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
if (WIN32)
  cmake_minimum_required( VERSION 3.10.0 FATAL_ERROR)
else()
  cmake_minimum_required( VERSION 3.10.0 FATAL_ERROR)
endif()

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake" ${CMAKE_MODULE_PATH})
include(ExternalProject)
include(ExternalProjectDependency)

set(PRIMARY_PROJECT_NAME SyneRBI)
option(${PRIMARY_PROJECT_NAME}_SUPERBUILD "Build ${PRIMARY_PROJECT_NAME} and the projects it depends on via SuperBuild.cmake." ON)

if(${PRIMARY_PROJECT_NAME}_SUPERBUILD)

    project(SuperBuild_${PRIMARY_PROJECT_NAME})
    include("${CMAKE_CURRENT_SOURCE_DIR}/SuperBuild.cmake")
    return()
else()
    project(${PRIMARY_PROJECT_NAME})
    include("${CMAKE_CURRENT_SOURCE_DIR}/${PRIMARY_PROJECT_NAME}.cmake")
    return()
endif()

message(FATAL_ERROR "Something has gone horribly wrong!")
