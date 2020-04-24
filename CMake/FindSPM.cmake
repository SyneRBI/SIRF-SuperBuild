#========================================================================
# Author: Richard Brown
# Copyright 2019, 2020 University College London
#
# This file is part of the CCP SyneRBI (formerly PETMR) Synergistic Image Reconstruction Framework (SIRF) SuperBuild.
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

if (NOT SPM_DIR)
  set(SPM_DIR "" CACHE PATH "Path to SPM")
endif()

find_file(spm_realign "spm_realign.m" PATHS "${SPM_DIR}" NO_DEFAULT_PATH)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SPM
  FOUND_VAR SPM_FOUND
  REQUIRED_VARS spm_realign
)

unset(spm_realign CACHE)