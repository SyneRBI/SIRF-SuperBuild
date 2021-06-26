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

# configure nbstripout
git config --global filter.nbstripout.extrakeys '
  metadata.celltoolbar metadata.language_info.codemirror_mode.version
  metadata.language_info.pygments_lexer metadata.language_info.version'
  
nbstripout --install
# jupyter labextension install @jupyter-widgets/jupyterlab-manager
