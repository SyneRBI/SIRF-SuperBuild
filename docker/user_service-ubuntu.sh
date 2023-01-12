#!/usr/bin/env bash
[ -f .bashrc ] && . .bashrc
set -ev
INSTALL_DIR="${1:-/opt}"
if [ -n "${PYTHON_EXECUTABLE}" ]; then 
  PYTHON=$PYTHON_EXECUTABLE
else
  PYTHON='miniconda'
fi

# SIRF-Exercises
git clone https://github.com/SyneRBI/SIRF-Exercises --recursive -b master $INSTALL_DIR/SIRF-Exercises

if [ "$PYTHON" = "miniconda" ]; then
  # updates the various packages
  conda update -c conda-forge -y --all
  if [ -f requirements-service.yml ]; then
    # installs the required packages in the environment with requirements-service.yml. 
    # Notice that these requirements TEMPORARILY contains also the packages for SIRF-Exercises
    mamba env update --file requirements-service.yml 
  fi
  conda clean -y --all

# Python (runtime)
else
  if [ -f requirements-service.txt ]; then
    pip install -U -r requirements-service.txt
  fi
  #install SIRF-Exercises requirements
  cd $INSTALL_DIR/SIRF-Exercises
  if [ -f requirements.txt ]; then
    python ~/install-sirf-exercises-dep.py requirements.txt
    # mamba install -c conda-forge -y --file requirements.txt || \
    # pip install -U -r requirements.txt
  fi
fi


# configure nbstripout
git config --global filter.nbstripout.extrakeys '
  metadata.celltoolbar metadata.language_info.codemirror_mode.version
  metadata.language_info.pygments_lexer metadata.language_info.version'

#install nbstripout in the SIRF-Exercises repo
cd $INSTALL_DIR/SIRF-Exercises  
nbstripout --install
# jupyter labextension install @jupyter-widgets/jupyterlab-manager

# CIL-Demos
git clone https://github.com/TomographicImaging/CIL-Demos.git --recursive -b main $INSTALL_DIR/CIL-Demos
cd $INSTALL_DIR/CIL-Demos
nbstripout --install
