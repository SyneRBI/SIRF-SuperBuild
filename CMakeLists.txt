cmake_minimum_required( VERSION 3.7.0 FATAL_ERROR)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake" ${CMAKE_MODULE_PATH})
include(version_config.cmake)
include(ExternalProject)
include(ExternalProjectDependency)

# enable ccache https://ccache.samba.org/
find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
    set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "${CCACHE_PROGRAM}")
endif()

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
