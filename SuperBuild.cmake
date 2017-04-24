
set( SOURCE_DOWNLOAD_CACHE ${CMAKE_CURRENT_BINARY_DIR} CACHE PATH
    "The path for downloading external source directories" )

set(externalProjName ${PRIMARY_PROJECT_NAME})
set(proj ${PRIMARY_PROJECT_NAME})

mark_as_advanced( SOURCE_DOWNLOAD_CACHE )

include(ExternalProject)

set(EXTERNAL_PROJECT_BUILD_TYPE "Release" CACHE STRING "Default build type for support libraries")
set_property(CACHE EXTERNAL_PROJECT_BUILD_TYPE PROPERTY
STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")


set(MATLAB_ROOT CACHE PATH "Path to Matlab root directory")

option(USE_SYSTEM_BOOST "Build using an external version of Boost" OFF)
option(USE_SYSTEM_STIR "Build using an external version of STIR" OFF)
option(USE_SYSTEM_HDF5 "Build using an external version of HDF5" OFF)
option(USE_SYSTEM_ISMRMRD "Build using an external version of ISMRMRD" OFF)
option(USE_SYSTEM_FFTW3 "Build using an external version of fftw" OFF)
option(USE_SYSTEM_SIRF "Build using an external version of SIRF" OFF)

option(BUILD_GADGETRON "Build Gadgetron" ON)

set(${PRIMARY_PROJECT_NAME}_DEPENDENCIES
    Boost
    googletest
    SWIG
    HDF5
    FFTW3
    ismrmrd
    STIR
    SIRF
)
if (BUILD_GADGETRON)
    list(APPEND ${PRIMARY_PROJECT_NAME}_DEPENDENCIES Gadgetron)
endif()

ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${PRIMARY_PROJECT_NAME}_DEPENDENCIES)

message(STATUS "")
message(STATUS "BOOST_ROOT = " ${BOOST_ROOT})
message(STATUS "ISMRMRD_ROOT = " ${ISMRMRD_ROOT})
message(STATUS "FFTW3_ROOT_DIR = " ${FFTW3_ROOT_DIR})
message(STATUS "STIR_DIR = " ${STIR_DIR})
message(STATUS "HDF5_ROOT = " ${HDF5_ROOT})
message(STATUS "MATLAB_ROOT = " ${MATLAB_ROOT})

#set(SIRF_Install_Dir ${CMAKE_CURRENT_BINARY_DIR}/SIRF-install)
#set(SIRF_URL https://github.com/CCPPETMR/SIRF )
#message(STATUS "HDF5_ROOT for SIRF: " ${HDF5_ROOT})

#Need to configure main project here.
#set(proj ${PRIMARY_PROJECT_NAME})
