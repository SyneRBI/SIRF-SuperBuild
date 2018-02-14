#!/usr/bin/env bash
pip install -U nose
pushd /opt/SIRF-SuperBuild

./INSTALL/bin/gadgetron >& gadgetron.log&
# print for debugging
cat SIRF-prefix/src/SIRF-build/CMakeCache.txt
ctest -VV
ret=$?
# print for debugging
cat SIRF-prefix/src/SIRF-build/Testing/Temporary/LastTest.log
# may exceed 4MB travis log limit
cat gadgetron.log
popd
exit $ret
