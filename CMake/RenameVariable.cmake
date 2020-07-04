#========================================================================
# Author: Kris Thielemans
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

# This defines a macro that can be used to replace a variable called OLD with one called NEW.
# It will write a warning, set DEFAULT_VAR to the value of OLD, and unset OLD.
# Example usage:
#   RenameVariable(BUILD_GADGETRON BUILD_Gadgetron build_Gadgetron_default)
#   option(BUILD_Gadgetron "Build Gadgetron" ${build_Gadgetron_default})

macro(RenameVariable OLD NEW DEFAULT_VAR)
  if (DEFINED ${OLD})
    message(WARNING "Obsolete use of ${OLD}. I have used its value to set the default for ${NEW} (use that variable in future!)")
    set(${DEFAULT_VAR} ${${OLD}})
    unset(${OLD} CACHE)
  endif()
endmacro()

