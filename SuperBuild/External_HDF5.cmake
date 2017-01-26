#These need to be unique globally
set(externalProjName HDF5)
set(proj HDF5)

# Set dependency list
set(${proj}_DEPENDENCIES "")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here
  set(HDF5_Install_Dir ${CMAKE_CURRENT_BINARY_DIR}/INSTALL)
  #set(HDF5_Configure_Script ${CMAKE_CURRENT_LIST_DIR}/External_HDF5_configureboost.cmake)
  #set(HDF5_Build_Script ${CMAKE_CURRENT_LIST_DIR}/External_HDF5_buildboost.cmake)

  set(${proj}_URL https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.0-patch1/src/CMake-hdf5-1.10.0-patch1.tar.gz )
  set(${proj}_MD5 6fb456d03a60f358f3c077288a6d1cd8 )

  if(CMAKE_COMPILER_IS_CLANGXX)
    set(CLANG_ARG -DCMAKE_COMPILER_IS_CLANGXX:BOOL=ON)
  endif()

  set(HDF5_SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj}-prefix/src/HDF5/hdf5-1.10.0-patch1 )

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    URL ${${proj}_URL}
    URL_HASH MD5=${${proj}_MD5}
    #SOURCE_DIR ${HDF5_SOURCE_DIR}/hdf5-1.10.0-patch1
    BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/${proj}
    CONFIGURE_COMMAND ${CMAKE_COMMAND}
                             ${CLANG_ARG}
                             -DCMAKE_INSTALL_PREFIX:PATH=${HDF5_Install_Dir} "${HDF5_SOURCE_DIR}"

    #BUILD_COMMAND ${CMAKE_COMMAND}
    #                         -DBUILD_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}/${proj}
    #                         -DINSTALL_DIR:PATH=${HDF5_Install_Dir}
    INSTALL_DIR ${HDF5_Install_Dir}
  )

  #set(HDF5_ROOT        ${HDF5_SOURCE_DIR})
  #set(HDF5_INCLUDE_DIR ${HDF5_SOURCE_DIR})

  set( HDF5_ROOT ${HDF5_Install_Dir} )
  set( HDF5_INCLUDE_DIRS ${HDF5_ROOT}/include )

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
