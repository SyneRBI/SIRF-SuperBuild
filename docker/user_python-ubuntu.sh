#!/usr/bin/env bash

# User can pass 2 parameters to this script: 
# 1. PYTHON_EXECUTABLE which can be either the 'miniconda' string or the location of the Python executable
# 2. PYTHON_INSTALL_DIR which points to the location where the user has their virtual environment installed
#    The virtual environment can be either virtualenv or conda
#
# To pass these parameters the user needs to set (at least) temporary environment variables:
# PYTHON_EXECUTABLE=python3 PYTHON_INSTALL_DIR="~/virtualenv" bash user_python-ubuntu.sh
# For details see https://github.com/SyneRBI/SIRF-SuperBuild/pull/692#issuecomment-1102704682 
[ -f .bashrc ] && . .bashrc
set -exv

if [ -n "${PYTHON_EXECUTABLE}" ]; then 
  PYTHON=$PYTHON_EXECUTABLE
else
  PYTHON='miniconda'
fi

if [[ -n "${PYTHON_INSTALL_DIR}" ]]; then
  INSTALL_DIR=${PYTHON_INSTALL_DIR}
else
  INSTALL_DIR="/opt/conda"
fi

# Python
case "$PYTHON" in
miniconda)
  # miniconda
  curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh > miniconda.sh
  echo -e "\nyes\n${INSTALL_DIR}" | bash miniconda.sh
  rm miniconda.sh
  source "$INSTALL_DIR"/bin/activate
  conda config --add channels conda-forge
  # https://github.com/conda/conda/issues/6030
  #conda update -c conda-forge -y conda
  conda update -c conda-forge -y setuptools pip mamba
  ;;
*python*)
  # virtualenv
  curl $($PYTHON get_pip_download_link.py) > get-pip.py
  ${PYTHON} get-pip.py
  rm get-pip.py
  ${PYTHON} -m pip install -U pip virtualenv
  ${PYTHON} -m virtualenv "$INSTALL_DIR"
  source "$INSTALL_DIR"/bin/activate
  ;;
*)
  >&2 echo "unknown '\$PYTHON' '$PYTHON'"
  exit 1
  ;;
esac

if [ "$PYTHON" = "miniconda" ]; then
  if [ -f requirements.yml ]; then
    # installs the required packages in the environment with requirements.yml. 
    # Notice that SciPy is set to 1.7.3 to prevent `GLIBCXX_3.4.30' not found
    mamba env update --file requirements.yml 
  fi
  mamba clean -y --all
# Python (runtime)
else
  if [ -f requirements.txt ]; then
    pip install -U -r requirements.txt
  fi
fi
