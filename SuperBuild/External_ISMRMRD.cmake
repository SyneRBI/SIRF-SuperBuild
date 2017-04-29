#This needs to be unique globally
set(proj ISMRMRD)

# Set dependency list
set(${proj}_DEPENDENCIES "HDF5;Boost;FFTW3")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here
  set(ISMRMRD_Install_Dir ${CMAKE_CURRENT_BINARY_DIR}/INSTALL)

  set(${proj}_URL https://github.com/CCPPETMR/ISMRMRD )

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    GIT_REPOSITORY ${${proj}_URL}
    SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj}
    #BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/${proj}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${ISMRMRD_Install_Dir}
            -DCMAKE_PREFIX_PATH=${CMAKE_CURRENT_BINARY_DIR}/INSTALL
            -DCMAKE_LIBRARY_PATH=${CMAKE_CURRENT_BINARY_DIR}/INSTALL/lib
            -DHDF5_ROOT=${HDF5_ROOT}
	    -DHDF5_INCLUDE_DIRS=${HDF5_INCLUDE_DIRS}
	    -DHDF5_LIBRARIES=${HDF5_LIBRARIES}
            -DBOOST_ROOT=${BOOST_ROOT}
    INSTALL_DIR ${ISMRMRD_Install_Dir}
    DEPENDS
        ${${proj}_DEPENDENCIES}
  )

    set(ISMRMRD_DIR        ${ISMRMRD_Install_Dir}/lib/cmake/ISMRMRD)

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
