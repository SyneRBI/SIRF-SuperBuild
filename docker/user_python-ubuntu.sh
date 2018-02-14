#!/usr/bin/env bash
[ -f .bashrc ] && . .bashrc
INSTALL_DIR="${1:-/opt/pyvenv}"

# Python (virtualenv)
curl https://bootstrap.pypa.io/get-pip.py > get-pip.py
python2 get-pip.py
rm get-pip.py
python2 -m pip install -U pip virtualenv
python2 -m virtualenv "$INSTALL_DIR"
source "$INSTALL_DIR"/bin/activate

# Python (runtime)
if [ -f requirements.txt ]; then
  pip install -U -r requirements.txt
fi
