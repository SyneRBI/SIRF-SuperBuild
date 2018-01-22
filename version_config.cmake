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
set(Boost_REQUIRED_VERSION 1.36.0)
set(Boost_URL http://downloads.sourceforge.net/project/boost/boost/1.63.0/boost_1_63_0.zip)
set(Boost_MD5 3c706b3fc749884ea5510c39474fd732)

## Armadillo
set(Armadillo_URL   https://downloads.sourceforge.net/project/arma/armadillo-7.800.2.tar.xz)
set(Armadillo_MD5 c601f3a5ec6d50666aa3a539fa20e6ca )

## FFTW3
if(WIN32)
  # Just use precompiled version
  # TODO would prefer the next zip file but for KT using an ftp URL times-out (firewall?)
  set(FFTW3_URL ftp://ftp.fftw.org/pub/fftw/fftw-3.3.5-dll64.zip )
  set(FFTW3_MD5 cb3c5ad19a89864f036e7a2dd5be168c )
  #set(FFTW3_URL https://s3.amazonaws.com/install-gadgetron-vs2013/Dependencies/FFTW/zip/FFTW3.zip )
  #set(FFTW3_MD5 a42eac92d9ad06d7c53fb82b09df2b6e )
else(WIN32)
  set(FFTW3_URL http://www.fftw.org/fftw-3.3.5.tar.gz ) 
  set(FFTW3_MD5 6cc08a3b9c7ee06fdd5b9eb02e06f569 )
endif(WIN32)

set(FFTW3double_URL ${FFTW3_URL})
set(FFTW3double_MD5 ${FFTW3_MD5})

## HDF5
if (WIN32)
  # 1.8.15 hdf5-targets.cmake refers to non-existent zlib files
  # (or at least this was the case for older Anaconda installations)
  set(HDF5_REQUIRED_VERSION 1.8.17)
else()
  set(HDF5_REQUIRED_VERSION 1.8)
endif()
set(HDF5_URL https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.1/src/hdf5-1.10.1.tar.gz)
set(HDF5_MD5 43a2f9466702fb1db31df98ae6677f15 )

## SWIG
set (SWIG_REQUIRED_VERSION 2)
if (WIN32)
  set(SWIG_URL http://downloads.sourceforge.net/swig/swigwin-3.0.12.zip  )
  set(SWIG_MD5 a49524dad2c91ae1920974e7062bfc93 )
else(WIN32)
  set(SWIG_URL http://downloads.sourceforge.net/swig/swig-3.0.12.tar.gz )
  set(SWIG_MD5 82133dfa7bba75ff9ad98a7046be687c )
endif(WIN32)
option(DEVEL_BUILD "Use current versions of major packages" OFF)

## Googletest
set(GTest_URL https://github.com/google/googletest )
set(GTest_TAG release-1.8.0)

## ITK
set(ITK_URL https://itk.org/ITK.git)
set(ITK_TAG v4.13.0)

option (DEVEL_BUILD "Developer Build" OFF)
mark_as_advanced(DEVEL_BUILD)

#Set the default versions for SIRF, STIR, Gadgetron and ISMRMRD
# with devel build it uses latest version of upstream packages
# otherwise uses the versions for current SIRF

set(DEFAULT_SIRF_URL https://github.com/CCPPETMR/SIRF )
if (DEVEL_BUILD)
  set (DEFAULT_SIRF_TAG master)
  ## STIR
  set(DEFAULT_STIR_URL https://github.com/UCL/STIR )
  set(DEFAULT_STIR_TAG master)

  ## Gadgetron
  set(DEFAULT_Gadgetron_URL https://github.com/gadgetron/gadgetron )
  set(DEFAULT_Gadgetron_TAG master)

  ## siemens_to_ismrmrd
  set(DEFAULT_siemens_to_ismrmrd_URL https://github.com/ismrmrd/siemens_to_ismrmrd )
  set(DEFAULT_siemens_to_ismrmrd_TAG master)

  ## ISMRMRD
  set(DEFAULT_ISMRMRD_URL https://github.com/ismrmrd/ismrmrd )
  set(DEFAULT_ISMRMRD_TAG master)

else()
  set(DEFAULT_SIRF_TAG v0.9.2)

  ## STIR
  set(DEFAULT_STIR_URL https://github.com/UCL/STIR )
  set(DEFAULT_STIR_TAG 41651b3a2007c58cbf1f7706bb2e269a21e870b1)

  ## Gadgetron
  set(DEFAULT_Gadgetron_URL https://github.com/gadgetron/gadgetron )
  #https://github.com/CCPPETMR/gadgetron) 

  set(DEFAULT_Gadgetron_TAG e7eb430673eb3272e8a821b51750c0a2a96dafed )
  #set(DEFAULT_Gadgetron_TAG 00b96376568278a595e78879026bb3b0d5fbb98d )

  ## siemens_to_ismrmrd
  set(DEFAULT_siemens_to_ismrmrd_URL https://github.com/ismrmrd/siemens_to_ismrmrd)
  set(DEFAULT_siemens_to_ismrmrd_TAG ba4773f9cf4bba5f3ccd19930e3548d8273fee01)

  ## ISMRMRD
  set(DEFAULT_ISMRMRD_URL https://github.com/ismrmrd/ismrmrd )
  set(DEFAULT_ISMRMRD_TAG 42d93137cc16c270c8ba065edd2496483161bd21)

endif()


# Set the tags for SIRF, STIR, Gadgetron and ISMRMRD
# these can be overridden by the user
SET(SIRF_URL ${DEFAULT_SIRF_URL} CACHE STRING ON)
SET(SIRF_TAG ${DEFAULT_SIRF_TAG} CACHE STRING ON)
 
SET(STIR_TAG ${DEFAULT_STIR_TAG} CACHE STRING ON)
SET(STIR_URL ${DEFAULT_STIR_URL} CACHE STRING ON)

SET(Gadgetron_TAG ${DEFAULT_Gadgetron_TAG} CACHE STRING ON)
SET(Gadgetron_URL ${DEFAULT_Gadgetron_URL} CACHE STRING ON)

SET(siemens_to_ismrmrd_TAG ${DEFAULT_siemens_to_ismrmrd_TAG} CACHE STRING ON)
SET(siemens_to_ismrmrd_URL ${DEFAULT_siemens_to_ismrmrd_URL} CACHE STRING ON)

SET(ISMRMRD_TAG ${DEFAULT_ISMRMRD_TAG} CACHE STRING ON)
SET(ISMRMRD_URL ${DEFAULT_ISMRMRD_URL} CACHE STRING ON)

mark_as_advanced(SIRF_URL SIRF_TAG STIR_URL STIR_TAG
  Gadgetron_URL Gadgetron_TAG
  siemens_to_ismrmrd_URL siemens_to_ismrmrd_TAG
  ISMRMRD_URL ISMRMRD_TAG)
