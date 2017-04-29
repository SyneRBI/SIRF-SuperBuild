#This needs to be unique globally
set(proj googletest)

# Set dependency list
set(${proj}_DEPENDENCIES "")

#message(STATUS "MATLAB_ROOT=" ${MATLAB_ROOT})
#message(STATUS "STIR_DIR=" ${STIR_DIR})

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here
  set(googletest_Install_Dir ${CMAKE_CURRENT_BINARY_DIR}/INSTALL)
  set(${proj}_URL https://github.com/google/googletest )

  #message(STATUS "HDF5_ROOT in External_SIRF: " ${HDF5_ROOT})
  set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} ${CMAKE_CURRENT_BINARY_DIR}/INSTALL)
  set(CMAKE_INCLUDE_PATH ${CMAKE_INCLUDE_PATH} ${CMAKE_CURRENT_BINARY_DIR}/INSTALL)

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    GIT_REPOSITORY ${${proj}_URL}
    SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj}

    CMAKE_ARGS
        -DCMAKE_PREFIX_PATH=${CMAKE_CURRENT_BINARY_DIR}/INSTALL
        -DCMAKE_LIBRARY_PATH=${CMAKE_CURRENT_BINARY_DIR}/INSTALL/lib
        -DCMAKE_INCLUDE_PATH=${CMAKE_CURRENT_BINARY_DIR}/INSTALL
        -DCMAKE_INSTALL_PREFIX=${googletest_Install_Dir}
    #    -DBOOST_INCLUDEDIR=${BOOST_ROOT}/include/
    #    -DBOOST_LIBRARYDIR=${BOOST_LIBRARY_DIR}
    #    -DMATLAB_ROOT=${MATLAB_ROOT}
    #    -DHDF5_ROOT=${HDF5_ROOT}
    #    -DHDF5_INCLUDE_DIRS=${HDF5_INCLUDE_DIRS}
    #    -Dismrmrd_DIR=${ismrmrd_ROOT}
    #    -Dismrmrd_INCLUDE_DIRS=${ismrmrd_INCLUDE_DIRS}
    INSTALL_DIR ${googletest_Install_Dir}
    DEPENDS
        ${${proj}_DEPENDENCIES}
  )

    set(googletest_ROOT        ${googletest_SOURCE_DIR})
    set(googletest_INCLUDE_DIR ${googletest_SOURCE_DIR})

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

