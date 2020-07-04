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

message("Performing SIRF's custom NiftyPET install")

## Install headers
file(GLOB_RECURSE HDRS RELATIVE ${NiftyPET_SOURCE_DIR} ${NiftyPET_SOURCE_DIR}/*.h)
FOREACH(HDR ${HDRS})
  get_filename_component(path_to_copy_to "${SUPERBUILD_INSTALL_DIR}/include/${HDR}" DIRECTORY)
  file(COPY ${NiftyPET_SOURCE_DIR}/${HDR} DESTINATION ${path_to_copy_to})
ENDFOREACH()

## Install libraries
file(COPY ${NiftyPET_BINARY_DIR}/nipet/prj/petprj.so DESTINATION ${SUPERBUILD_INSTALL_DIR}/lib)
file(COPY ${NiftyPET_BINARY_DIR}/nipet/mmr_auxe.so DESTINATION ${SUPERBUILD_INSTALL_DIR}/lib)
file(COPY ${NiftyPET_BINARY_DIR}/nipet/lm/mmr_lmproc.so DESTINATION ${SUPERBUILD_INSTALL_DIR}/lib)