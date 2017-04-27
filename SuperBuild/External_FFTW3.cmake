#These need to be unique globally
set(externalProjName FFTW3)
set(proj FFTW3)
set(proj_COMPONENTS "COMPONENTS single")
# Set dependency list
set(${proj}_DEPENDENCIES "")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here
  set(FFTW_Install_Dir ${CMAKE_CURRENT_BINARY_DIR}/INSTALL)
  set(FFTW_Configure_Script ${CMAKE_CURRENT_LIST_DIR}/External_FFTW_configure.cmake)
  set(FFTW_Build_Script ${CMAKE_CURRENT_LIST_DIR}/External_FFTW_build.cmake)

  set(${proj}_URL http://www.fftw.org/fftw-3.3.5.tar.gz )
  set(${proj}_MD5 6cc08a3b9c7ee06fdd5b9eb02e06f569 )
  
  if(CMAKE_COMPILER_IS_CLANGXX)
    set(CLANG_ARG -DCMAKE_COMPILER_IS_CLANGXX:BOOL=ON)
  endif()

if (WIN32)
  # Just use precompiled version
  # TODO would prefer the next zip file but for KT using an ftp URL times-out (firewall?)
  #set(${proj}_URL ftp://ftp.fftw.org/pub/fftw/fftw-3.3.5-dll64.zip )
  #set(${proj}_MD5 cb3c5ad19a89864f036e7a2dd5be168c )
  set(${proj}_URL https://s3.amazonaws.com/install-gadgetron-vs2013/Dependencies/FFTW/zip/FFTW3.zip )
  set(${proj}_MD5 a42eac92d9ad06d7c53fb82b09df2b6e )

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    URL ${${proj}_URL}
    URL_HASH MD5=${${proj}_MD5}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory ${FFTW_Install_Dir}
        COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> ${FFTW_Install_Dir}/FFTW
  )
  set( FFTW3_ROOT_DIR ${FFTW_Install_Dir}/FFTW )
else()
  set(FFTW_SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj} )
  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    URL ${${proj}_URL}
    URL_HASH MD5=${${proj}_MD5}
    SOURCE_DIR ${FFTW_SOURCE_DIR}
    BINARY_DIR ${FFTW_SOURCE_DIR}
    CONFIGURE_COMMAND ./configure --enable-float --with-pic --prefix ${FFTW_Install_Dir}
    INSTALL_DIR ${FFTW_Install_Dir}
  )
  set( FFTW3_ROOT_DIR ${FFTW_Install_Dir} )
endif()


 else()
    if(${USE_SYSTEM_${externalProjName}})
      find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} ${${externalProjName}_COMPONENTS} REQUIRED)
      message(STATUS "USING the system ${externalProjName}, found FFTW3_INCLUDE_DIR=${FFTW3_INCLUDE_DIR}, FFTW3_LIBRARY=${FFTW3_LIBRARY}")
  endif()
  ExternalProject_Add_Empty(${proj} "${${proj}_DEPENDENCIES}")
endif()

mark_as_superbuild(
  VARS
    ${externalProjName}_DIR:PATH
  LABELS
    "FIND_PACKAGE"
)
