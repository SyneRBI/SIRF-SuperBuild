#========================================================================
# Author: Benjamin A Thomas
# Copyright 2017, 2020 University College London
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

if(WIN32)
  execute_process(COMMAND bootstrap.bat
    WORKING_DIRECTORY ${BUILD_DIR} RESULT_VARIABLE bootstrap_result)
else()
  message(STATUS "Build dir is : ${BUILD_DIR}")
  execute_process(COMMAND ./bootstrap.sh --prefix=${BOOST_INSTALL_DIR}
    --with-libraries=system,filesystem,thread,program_options,chrono,date_time,atomic,timer,regex,test,coroutine,context,random
    #--with-libraries=system,thread,program_options,log,math...
    #--without-libraries=atomic...

    WORKING_DIRECTORY ${BUILD_DIR} RESULT_VARIABLE bootstrap_result)
endif(WIN32)

return(${bootstrap_result})
