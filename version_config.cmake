#========================================================================
# Author: Edoardo Pasca
# Author: Benjamin A Thomas
# Author: Kris Thielemans
# Copyright 2017 University College London
# Copyright 2017 Science Technology Facilities Council
#
# This file is part of the CCP PETMR Synergistic Image Reconstruction Framework (SIRF) SuperBuild.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0.txt
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#=========================================================================

## BOOST
set(Boost_VERSION 1.63.0)
set(Boost_URL http://downloads.sourceforge.net/project/boost/boost/1.63.0/boost_1_63_0.zip)
set(Boost_MD5 3c706b3fc749884ea5510c39474fd732)

## Armadillo
set(Armadillo_URL   https://downloads.sourceforge.net/project/arma/armadillo-7.800.2.tar.xz?r=http%3A%2F%2Farma.sourceforge.net%2Fdownload.html&ts=1492950217&use_mirror=freefr
 )
set(Armadillo_MD5 c601f3a5ec6d50666aa3a539fa20e6ca )

## FFTW3
if(WIN32)
  # Just use precompiled version
  # TODO would prefer the next zip file but for KT using an ftp URL times-out (firewall?)
  #set(${proj}_URL ftp://ftp.fftw.org/pub/fftw/fftw-3.3.5-dll64.zip )
  #set(${proj}_MD5 cb3c5ad19a89864f036e7a2dd5be168c )
  set(FFTW3_URL https://s3.amazonaws.com/install-gadgetron-vs2013/Dependencies/FFTW/zip/FFTW3.zip )
  set(FFTW3_MD5 a42eac92d9ad06d7c53fb82b09df2b6e )
else(WIN32)
  set(FFTW3_URL http://www.fftw.org/fftw-3.3.5.tar.gz ) 
  set(FFTW3_MD5 6cc08a3b9c7ee06fdd5b9eb02e06f569 )
endif(WIN32)

set(FFTW3double_URL ${FFTW3_URL})
set(FFTW3double_MD5 ${FFTW3_MD5})




## HDF5
set(HDF5_URL https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.0-patch1/src/CMake-hdf5-1.10.0-patch1.tar.gz )
set(HDF5_MD5 6fb456d03a60f358f3c077288a6d1cd8 )

## SWIG
if (WIN32)
  set(SWIG_URL http://prdownloads.sourceforge.net/swig/swigwin-3.0.12.zip  )
  set(SWIG_MD5 a49524dad2c91ae1920974e7062bfc93 )
else(WIN32)
  set(SWIG_URL http://prdownloads.sourceforge.net/swig/swig-3.0.12.tar.gz )
  set(SWIG_MD5 82133dfa7bba75ff9ad98a7046be687c )
endif(WIN32)
option(DEVEL_BUILD "Use current versions of major packages" OFF)

## Googletest
set(googletest_URL https://github.com/google/googletest )
set(googletest_TAG release-1.8.0)

option (DEVEL_BUILD "Developer Build" OFF)
#SIRF
set(SIRF_URL https://github.com/CCPPETMR/SIRF )
if (DEVEL_BUILD)
  set (SIRF_TAG master)
  ## STIR
  set(STIR_URL https://github.com/UCL/STIR )
  set(STIR_TAG master)

  ## Gadgetron
  set(Gadgetron_URL https://github.com/gadgetron/gadgetron )
  set(Gadgetron_TAG master)

  ## ISMRMRD
  set(ISMRMRD_URL https://github.com/ismrmrd/ismrmrd )
  set(ISMRMRD_TAG master)

else()
  set(SIRF_TAG v0.9.0)
  ## STIR
  set(STIR_URL https://github.com/CCPPETMR/STIR )
  set(STIR_TAG 8bf37d9d7fdde7cb3a98a6f848d93827dbd98a18)

  ## Gadgetron
  set(Gadgetron_URL https://github.com/CCPPETMR/gadgetron )
  set(Gadgetron_TAG f03829ef45e57466829e6ec46da7a7cf61db1c8a)

  ## ISMRMRD
  set(ISMRMRD_URL https://github.com/CCPPETMR/ismrmrd )
  set(ISMRMRD_TAG 35012c6c8000616546c2d6b1757eba0c5b21b2d4)

endif()
option(GIT_TAG_SIRF "git tag for SIRF" ${SIRF_TAG})

