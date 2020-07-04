#========================================================================
# Author: Benjamin A Thomas
# Copyright 2017, 2020 University College London
#
# This file is part of the CCP SyneRBI (formerly PETMR) Synergistic Image Reconstruction Framework (SIRF) SuperBuild.
##
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

if(WIN32)
  # TODO: would be better to use a variable but for some reason KT cannot pass the variable to the execute_process
  # without strange error messages of b2
  
  execute_process(COMMAND ./b2 --with-system --with-filesystem --with-thread --with-program_options --with-chrono --with-date_time --with-atomic  --with-timer --with-test install --prefix=${BOOST_INSTALL_DIR}
    WORKING_DIRECTORY ${BUILD_DIR} RESULT_VARIABLE build_result)

else(WIN32)
  # selection of libraries has happened in the configure step
  execute_process(COMMAND ./b2 install
    WORKING_DIRECTORY ${BUILD_DIR} RESULT_VARIABLE build_result)

endif(WIN32)

return(${build_result})
