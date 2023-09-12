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
git clone https://github.com/SyneRBI/SIRF-Exercises --recursive $INSTALL_DIR/SIRF-Exercises

#install SIRF-Exercises requirements
cd $INSTALL_DIR/SIRF-Exercises
if [ "$PYTHON" = "miniconda" ]; then
  if [ -f environment.yml ]; then
    if test "${BUILD_GPU:-0}" != 0; then
      # uncomment GPU deps
      sed -r 's/^(\s*)#\s*(- \S+.*#.*GPU.*)$/\1\2/' environment.yml > environment-sirf.yml
    else
      # delete GPU deps
      sed -r -e '/^\s*- (astra-toolbox|tigre).*/d' -e '/^\s*- \S+.*#.*GPU/d' environment.yml > environment-sirf.yml
    fi
    conda env update --file environment-sirf.yml
  else
    if [ -f requirements.txt ]; then
      cat requirements.txt
      # installing the requirements.txt with conda requires some cleaning of the requirements.txt
      # Also the requirements.txt contains some packages that are not found on conda-forge, i.e. brainweb
      # Therefore, these need to be installed by pip.
      # This is handled by the install-sirf-exercises-dep.py script
      python ~/install-sirf-exercises-dep.py requirements.txt
    else
      echo "SIRF-Exercises requirements: did not find requirements.txt nor environment.yml. Skipping"
    fi
  fi
else
  if [ -f requirements.txt ]; then
    # just install the requirements.txt with pip
    ${PYTHON} -m pip install -U -r requirements.txt
  else
    echo "SIRF-Exercises requirements: did not find requirements.txt. Skipping"
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
git clone https://github.com/TomographicImaging/CIL-Demos --recursive $INSTALL_DIR/CIL-Demos
cd $INSTALL_DIR/CIL-Demos
nbstripout --install
