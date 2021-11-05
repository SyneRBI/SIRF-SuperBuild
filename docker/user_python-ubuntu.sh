#!/usr/bin/env bash
[ -f .bashrc ] && . .bashrc
set -ev
INSTALL_DIR="${1:-/opt/pyvenv}"
PYTHON="${2:-miniconda}"

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
  conda update -c conda-forge -y setuptools pip
  ;;
*python*)
  # virtualenv
  curl https://bootstrap.pypa.io/get-pip.py > get-pip.py
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

# Python (runtime)
if [ -f requirements.txt ]; then
  pip install -U -r requirements.txt
fi

if [ "$PYTHON" = "miniconda" ]; then
  if [ -f requirements_conda_forge.txt ]; then
    conda install --yes -c conda-forge --file requirements_conda_forge.txt
  fi
  conda update -c conda-forge -y --all
  conda clean -y --all
fi
