# This file is part of the CCP SyneRBI (formerly PETMR) Synergistic Image Reconstruction Framework (SIRF) SuperBuild.
# Copyright 2021 Rutherford Appleton Laboratory STFC
#
# Author: Edoardo Pasca
#
# This is software developed for the Collaborative Computational
# Project in Synergistic Reconstruction for Biomedical Imaging (formerly CCP PETMR)
# (http://www.ccpsynerbi.ac.uk/).
#
# Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#       http://www.apache.org/licenses/LICENSE-2.0
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
import sys

with open(sys.argv[1], 'r') as f:
    testdata = f.read()
    updated = testdata.replace('../NFFT.h', "NFFT.h")
    updated = updated.replace('../nfft_export.h', "nfft_export.h")
with open(sys.argv[2], 'w') as fw:
    fw.write(updated)
