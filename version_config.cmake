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


set(Boost_VERSION 1.63.0)
set(Boost_URL http://downloads.sourceforge.net/project/boost/boost/1.63.0/boost_1_63_0.zip)
set(Boost_MD5 3c706b3fc749884ea5510c39474fd732)

set(STIR_TAG stir_rel_3_00)
set(GADGETRON_TAG v3.8.2)
set(ISMRMRD_TAG v1.3.2)

option(DEVEL_BUILD "Use current versions of major packages" OFF)

if (DEVEL_BUILD)
set (default_SIRF_GIT_TAG master)
else()
set(default_SIRF_GIT_TAG v0.9.0)
endif()
option(GIT_TAG_SIRF "git tag for SIRF" ${default_SIRF_GIT_TAG})
