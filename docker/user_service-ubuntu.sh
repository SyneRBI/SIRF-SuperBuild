#!/usr/bin/env bash
[ -f .bashrc ] && . .bashrc
set -ev
INSTALL_DIR="${1:-/opt}"

# SIRF-Exercises
git clone https://github.com/SyneRBI/SIRF-Exercises --recursive -b master $INSTALL_DIR/SIRF-Exercises

if [ -f requirements-service.txt ]; then
  conda install -c conda-forge -y --file requirements-service.txt || \
  pip install -U -r requirements-service.txt
fi

#install SIRF-Exercises requirements
cd $INSTALL_DIR/SIRF-Exercises
if [ -f requirements.txt ]; then
  conda install -c conda-forge -y --file requirements.txt || \
  pip install -U -r requirements.txt
fi
# jupyter labextension install @jupyter-widgets/jupyterlab-manager

# CIL-Demos
git clone https://github.com/TomographicImaging/CIL-Demos.git --recursive -b master $INSTALL_DIR/CIL-Demos
