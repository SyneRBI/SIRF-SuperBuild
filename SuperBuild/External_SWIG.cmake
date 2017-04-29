#This needs to be unique globally
set(proj SWIG)
set(proj_COMPONENTS "COMPONENTS single")
# Set dependency list
set(${proj}_DEPENDENCIES "")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here
  set(SWIG_Install_Dir ${CMAKE_CURRENT_BINARY_DIR}/INSTALL)
  set(SWIG_Configure_Script ${CMAKE_CURRENT_LIST_DIR}/External_SWIG_configure.cmake)
  set(SWIG_Build_Script ${CMAKE_CURRENT_LIST_DIR}/External_SWIG_build.cmake)

  set(${proj}_URL http://prdownloads.sourceforge.net/swig/swig-3.0.12.tar.gz )
  set(${proj}_MD5 82133dfa7bba75ff9ad98a7046be687c )

  if(CMAKE_COMPILER_IS_CLANGXX)
    set(CLANG_ARG -DCMAKE_COMPILER_IS_CLANGXX:BOOL=ON)
  endif()

  set(SWIG_SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj} )

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    URL ${${proj}_URL}
    URL_HASH MD5=${${proj}_MD5}
    SOURCE_DIR ${SWIG_SOURCE_DIR}
    BINARY_DIR ${SWIG_SOURCE_DIR}
    CONFIGURE_COMMAND ./configure --without-pcre --prefix ${SWIG_Install_Dir}
    INSTALL_DIR ${SWIG_Install_Dir}
  )

#The SWIG test-suite and examples are configured for the following languages:
#perl5 python 

  set( SWIG_EXECUTABLE ${SWIG_Install_Dir}/bin/swig )
  set( SWIG_VERSION "3.0.12" )
  #set( SWIG_ROOT ${FFTW_Install_Dir} )


 else()
    if(${USE_SYSTEM_${externalProjName}})
      find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} ${${externalProjName}_COMPONENTS} REQUIRED)
      message(STATUS "USING the system ${externalProjName}, found SWIG_EXECUTABLE=${SWIG_EXECUTABLE}, SWIG_VERSION=${SWIG_VERSION}")
  endif()
  ExternalProject_Add_Empty(${proj} "${${proj}_DEPENDENCIES}")
endif()

mark_as_superbuild(
  VARS
    ${externalProjName}_DIR:PATH
  LABELS
    "FIND_PACKAGE"
)
