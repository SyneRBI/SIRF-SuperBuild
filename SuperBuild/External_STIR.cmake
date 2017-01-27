#These need to be unique globally
set(externalProjName STIR)
set(proj STIR)

# Set dependency list
set(${proj}_DEPENDENCIES "Boost")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here
  set(STIR_Install_Dir ${CMAKE_CURRENT_BINARY_DIR}/INSTALL)

  set(${proj}_URL https://github.com/CCPPETMR/STIR )

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    GIT_REPOSITORY ${${proj}_URL}
    SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj}
    #BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/${proj}
    CMAKE_ARGS -DGRAPHICS=None
        -DBUILD_EXECUTABLES=OFF
        -DBUILD_TESTING=OFF
        -DBUILD_DOCUMENTATION=OFF
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON
        -DBOOST_ROOT=${BOOST_ROOT}
        -DCMAKE_INSTALL_PREFIX=${STIR_Install_Dir}
        -DGRAPHICS=None
    INSTALL_DIR ${STIR_Install_Dir}
    DEPENDS
        ${${proj}_DEPENDENCIES}
  )

  set(STIR_ROOT       ${STIR_Install_Dir})
  set(STIR_INCLUDE_DIRS ${STIR_ROOT}/stir)

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
