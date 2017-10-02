#!/usr/bin/env bash
# Python (virtualenv)
curl -O https://bootstrap.pypa.io/get-pip.py
sudo -H python get-pip.py
rm get-pip.py
sudo -H python -m pip install -U pip virtualenv
virtualenv ~/py2
export PIPINST="$HOME/py2/bin/pip install -U"

# Python (runtime)
$PIPINST docopt
#$PIPINST cython
$PIPINST matplotlib
#PIPINST scipy
git clone https://github.com/ismrmrd/ismrmrd-python-tools.git
$PIPINST ./ismrmrd-python-tools
