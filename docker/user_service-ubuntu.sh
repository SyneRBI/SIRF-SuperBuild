#!/usr/bin/env bash
[ -f .bashrc ] && . .bashrc
set -ev

if [ -f requirements-service.txt ]; then
  conda install -c conda-forge -y --file requirements-service.txt || \
  pip install -U -r requirements-service.txt
fi

jupyter labextension install @jupyter-widgets/jupyterlab-manager
