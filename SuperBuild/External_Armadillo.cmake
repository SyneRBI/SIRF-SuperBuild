#This needs to be unique globally
set(proj Armadillo)

# Set dependency list
set(${proj}_DEPENDENCIES "")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here
  set(${proj}_Install_Dir ${CMAKE_CURRENT_BINARY_DIR}/INSTALL)

  set(${proj}_URL   https://downloads.sourceforge.net/project/arma/armadillo-7.800.2.tar.xz?r=http%3A%2F%2Farma.sourceforge.net%2Fdownload.html&ts=1492950217&use_mirror=freefr
 )
  set(${proj}_MD5 c601f3a5ec6d50666aa3a539fa20e6ca )

  # name after extraction
  set(${proj}_location armadillo)

  if(CMAKE_COMPILER_IS_CLANGXX)
    set(CLANG_ARG -DCMAKE_COMPILER_IS_CLANGXX:BOOL=ON)
  endif()

  set(${proj}_SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj}-prefix/src/${${proj}_location} )

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    URL ${${proj}_URL}
    URL_HASH MD5=${${proj}_MD5}
    BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/${proj}
    CONFIGURE_COMMAND ${CMAKE_COMMAND}
                             ${CLANG_ARG}
                             -DCMAKE_INSTALL_PREFIX:PATH=${${proj}_Install_Dir} "${${proj}_SOURCE_DIR}"

    #BUILD_COMMAND ${CMAKE_COMMAND}
    #                         -DBUILD_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}/${proj}
    #                         -DINSTALL_DIR:PATH=${${proj}_Install_Dir}
    INSTALL_DIR ${${proj}_Install_Dir}
  )

  #set(${proj}_ROOT        ${${proj}_SOURCE_DIR})
  #set(${proj}_INCLUDE_DIR ${${proj}_SOURCE_DIR})

  set( ${proj}_ROOT ${${proj}_Install_Dir} )
  set( ${proj}_INCLUDE_DIRS ${${proj}_ROOT}/include )

 else()
    if(${USE_SYSTEM_${externalProjName}})
      find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} REQUIRED)
      message(STATUS "USING the system ${externalProjName}, found ${proj}_LIBRARIES=${${proj}_LIBRARIES}}")
  endif()
  ExternalProject_Add_Empty(${proj} "${${proj}_DEPENDENCIES}")
endif()

mark_as_superbuild(
  VARS
    ${externalProjName}_DIR:PATH
  LABELS
    "FIND_PACKAGE"
)
