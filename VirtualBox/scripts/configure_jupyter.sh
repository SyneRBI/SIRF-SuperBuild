#! /bin/bash

#========================================================================
# Author: Edoardo Pasca, Kris Thielemans
# Copyright 2018, 2023 University College London
#
# This file is part of the CCP SyneRBI Synergistic Image Reconstruction Framework (SIRF) virtual machine.
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

# configure jupyter notebook
mkdir -p ~/.jupyter
# Old file for nbserver
# TODO remove these lines in the future
echo "c.NotebookApp.ip = '0.0.0.0'" > ~/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.notebook_dir = u'/home/sirfuser/devel/'" >> ~/.jupyter/jupyter_notebook_config.py
# Trying to set the password, but this currently doesn't work
echo "c.NotebookApp.password = u'sha1:cbf03843d2bb:8729d2fbec60cacf6485758752789cd9989e756c'" \
  >> ~/.jupyter/jupyter_notebook_config.py

# New file since jupyterlab 3.0 or so
echo "c.ServerApp.ip = '0.0.0.0'" > ~/.jupyter/jupyter_server_config.py
echo "c.ServerApp.root_dir = u'/home/sirfuser/devel/'" >> ~/.jupyter/jupyter_server_config.py
echo "c.ServerApp.password = u'sha1:cbf03843d2bb:8729d2fbec60cacf6485758752789cd9989e756c'" \
  >> ~/.jupyter/jupyter_server_config.py
