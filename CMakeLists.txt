if (WIN32)
  cmake_minimum_required( VERSION 3.10.0 FATAL_ERROR)
else()
  cmake_minimum_required( VERSION 3.10.0 FATAL_ERROR)
endif()

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake" ${CMAKE_MODULE_PATH})
include(ExternalProject)
include(ExternalProjectDependency)

set(PRIMARY_PROJECT_NAME CCPPETMR)
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
