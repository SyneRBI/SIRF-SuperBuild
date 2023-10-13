#!/usr/bin/env bash
[ -f .bashrc ] && . .bashrc
set -euxo pipefail

mkdir cil_sirf_test
touch cil_sirf_test/__init__.py
DEFAULT_CIL_TAG=$(/opt/conda/bin/python -c 'import cil; print(f"v{cil.version.version}" if cil.version.commit_hash == "-1" else cil.version.commit_hash[1:])' | tail -n1)
for fname in test_SIRF.py utils.py testclass.py; do
  curl -fsSL https://raw.githubusercontent.com/TomographicImaging/CIL/$DEFAULT_CIL_TAG/Wrappers/Python/test/$fname > cil_sirf_test/$fname
done

$SIRF_PATH/../../INSTALL/bin/gadgetron >& ~/gadgetron.log&
/opt/conda/bin/python -m unittest discover -v ./cil_sirf_test -k GradientPET -k BlockDataContainer
for i in $(jobs -p); do kill -n 15 $i; done 2>/dev/null  # kill gadgetron
