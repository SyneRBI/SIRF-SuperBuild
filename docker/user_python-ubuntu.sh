#!/usr/bin/env bash
# Python (virtualenv)
curl -O https://bootstrap.pypa.io/get-pip.py
python get-pip.py --user
rm get-pip.py
python -m pip install -U --user pip virtualenv
python -m virtualenv ~/py2
export PIPINST="$HOME/py2/bin/pip install -U"

# Python (runtime)
$PIPINST -r requirements.txt
