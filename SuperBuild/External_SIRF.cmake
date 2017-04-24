#These need to be unique globally
set(externalProjName SIRF)
set(proj SIRF)

# Set dependency list
set(${proj}_DEPENDENCIES "STIR;Boost;HDF5;ISMRMRD;FFTW3;SWIG")

message(STATUS "MATLAB_ROOT=" ${MATLAB_ROOT})
message(STATUS "STIR_DIR=" ${STIR_DIR})

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here
  set(SIRF_Install_Dir ${CMAKE_CURRENT_BINARY_DIR}/INSTALL)
  set(${proj}_URL https://github.com/CCPPETMR/SIRF )

  message(STATUS "HDF5_ROOT in External_SIRF: " ${HDF5_ROOT})
  set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} ${CMAKE_CURRENT_BINARY_DIR}/INSTALL)

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    GIT_REPOSITORY ${${proj}_URL}
    SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj}

    CMAKE_ARGS
        -DCMAKE_PREFIX_PATH=${CMAKE_CURRENT_BINARY_DIR}/INSTALL
        -DCMAKE_LIBRARY_PATH=${CMAKE_CURRENT_BINARY_DIR}/INSTALL/lib
        -DCMAKE_INSTALL_PREFIX=${SIRF_Install_Dir}
        -DBOOST_INCLUDEDIR=${BOOST_ROOT}/include/
        -DBOOST_LIBRARYDIR=${BOOST_LIBRARY_DIR}
        -DMATLAB_ROOT=${MATLAB_ROOT}
        -DSTIR_DIR=${STIR_DIR}
        -DHDF5_ROOT=${HDF5_ROOT}
        -DHDF5_INCLUDE_DIRS=${HDF5_INCLUDE_DIRS}
        -DISMRMRD_DIR=${ISMRMRD_DIR}
    INSTALL_DIR ${SIRF_Install_Dir}
    DEPENDS
        ${${proj}_DEPENDENCIES}
  )

    set(SIRF_ROOT        ${SIRF_SOURCE_DIR})
    set(SIRF_INCLUDE_DIR ${SIRF_SOURCE_DIR})

   else()
      if(${USE_SYSTEM_${externalProjName}})
        find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} REQUIRED)
        message("USING the system ${externalProjName}, set ${externalProjName}_DIR=${${externalProjName}_DIR}")
    endif()
    ExternalProject_Add_Empty(${proj} "${${proj}_DEPENDENCIES}")
  endif()

  mark_as_superbuild(
    VARS
      ${externalProjName}_DIR:PATH
    LABELS
      "FIND_PACKAGE"
  )
