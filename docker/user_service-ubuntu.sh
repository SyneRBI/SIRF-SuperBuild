#!/usr/bin/env bash
[ -f .bashrc ] && . .bashrc
set -ev
INSTALL_DIR="${1:-/opt}"

source "$INSTALL_DIR"/pyvenv/bin/activate

# SIRF-Exercises
git clone https://github.com/SyneRBI/SIRF-Exercises --recursive -b master $INSTALL_DIR/SIRF-Exercises

if [ -f requirements-service.txt ]; then
  conda install -c conda-forge -y --file requirements-service.txt || \
  pip install -U -r requirements-service.txt
fi

if [ -f requirements-service-jupyterhub.txt ]; then
  conda install -c conda-forge -y --file requirements-service-jupyterhub.txt || \
  pip install -U -r requirements-service-jupyterhub.txt
fi

#install SIRF-Exercises requirements
cd $INSTALL_DIR/SIRF-Exercises
if [ -f requirements.txt ]; then
   # uses only the requirement name not --only-binary
   awk '{print $1}' requirements.txt > crequirements.txt
  conda install -c conda-forge -y --file crequirements.txt || \
  pip install -U -r requirements.txt
  if [ -f crequirements.txt ] ; then
    rm crequirements.txt
  fi
fi
# jupyter labextension install @jupyter-widgets/jupyterlab-manager

# CIL-Demos
git clone https://github.com/TomographicImaging/CIL-Demos.git --recursive -b main $INSTALL_DIR/CIL-Demos
