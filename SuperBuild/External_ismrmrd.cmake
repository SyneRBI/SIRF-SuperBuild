#These need to be unique globally
set(externalProjName ismrmrd)
set(proj ismrmrd)

# Set dependency list
set(${proj}_DEPENDENCIES "HDF5;Boost")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here
  set(ismrmrd_Install_Dir ${CMAKE_CURRENT_BINARY_DIR}/INSTALL)

  set(${proj}_URL https://github.com/ismrmrd/ismrmrd )

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    GIT_REPOSITORY ${${proj}_URL}
    SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj}
    #BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/${proj}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${ismrmrd_Install_Dir}
            -DHDF5_ROOT=${HDF5_ROOT}
            -DBOOST_ROOT=${BOOST_ROOT}
    INSTALL_DIR ${ismrmrd_Install_Dir}
  )

    set(ismrmrd_ROOT        ${ismrmrd_Install_Dir})
    set(ismrmrd_INCLUDE_DIRS ${ismrmrd_Install_Dir}/include)

   else()
      if(${USE_SYSTEM_${externalProjName}})
        find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} REQUIRED)
        message("USING the system ${externalProjName}, set ${externalProjName}_DIR=${${externalProjName}_DIR}")
    endif()
  endif()

  mark_as_superbuild(
    VARS
        ${externalProjName}_DIR:PATH
    LABELS
      "FIND_PACKAGE"
  )
