#This needs to be unique globally
set(proj Boost)

# Set dependency list
set(${proj}_DEPENDENCIES "")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here
  set(Boost_Install_Dir ${CMAKE_CURRENT_BINARY_DIR}/INSTALL)
  set(Boost_Configure_Script ${CMAKE_CURRENT_LIST_DIR}/External_Boost_configureboost.cmake)
  set(Boost_Build_Script ${CMAKE_CURRENT_LIST_DIR}/External_Boost_buildboost.cmake)

  set(${proj}_URL http://downloads.sourceforge.net/project/boost/boost/1.63.0/boost_1_63_0.zip )
  set(${proj}_MD5 3c706b3fc749884ea5510c39474fd732 )

  if(CMAKE_COMPILER_IS_CLANGXX)
    set(CLANG_ARG -DCMAKE_COMPILER_IS_CLANGXX:BOOL=ON)
  endif()

  set(BOOST_SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj})

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    URL ${${proj}_URL}
    URL_HASH MD5=${${proj}_MD5}
    SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj}
    #BINARY_DIR ${proj}-build
    BUILD_IN_SOURCE 1

    CONFIGURE_COMMAND ${CMAKE_COMMAND}
                             ${CLANG_ARG}
                             -DBUILD_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}/${proj}
                             -DBOOST_INSTALL_DIR:PATH=${Boost_Install_Dir}
                             -P ${Boost_Configure_Script}
    INSTALL_COMMAND ""
    BUILD_COMMAND ${CMAKE_COMMAND}
                             -DBUILD_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}/${proj}
                             -DBOOST_INSTALL_DIR:PATH=${Boost_Install_Dir} -P ${Boost_Build_Script}
  )

  set(BOOST_ROOT        ${Boost_Install_Dir})
  set(BOOST_INCLUDEDIR ${Boost_Install_Dir}/include)
  set(BOOST_LIBRARY_DIR ${Boost_Install_Dir}/lib)
  #set(Boost_INCLUDE_DIR ${BOOST_SOURCE_DIR})


 else()
    if(${USE_SYSTEM_${externalProjName}})
      find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} REQUIRED)
      message("USING the system ${externalProjName}, using BOOST_LIBRARY_DIR=${BOOST_LIBRARY_DIR}")
  endif()
   ExternalProject_Add_Empty(${proj} "${${proj}_DEPENDENCIES}")
endif()

mark_as_superbuild(
  VARS
    ${externalProjName}_DIR:PATH
  LABELS
    "FIND_PACKAGE"
)
