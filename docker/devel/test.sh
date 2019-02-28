#!/usr/bin/env bash

## Usage:
# test.sh [<DEBUG_LEVEL>]
#
# Arguments:
#   <DEBUG_LEVEL>  : [default: 0]
##

DEBUG="${1:-0}"
this=$(dirname "${BASH_SOURCE[0]}")

pip install -U -r "$this"/requirements-test.txt

pushd $SIRF_PATH/../..

# start gadgetron
GCONFIG=./INSTALL/share/gadgetron/config/gadgetron.xml
[ -f "$GCONFIG" ] || cp "$GCONFIG".example "$GCONFIG"
./INSTALL/bin/gadgetron >& gadgetron.log&

ctest -VV
ret=$?
kill -n 15 $(pidof gadgetron)

# print for debugging
[ "$DEBUG" != 0 ] && cat builds/SIRF/build/CMakeCache.txt
[ "$DEBUG" != 0 ] && cat builds/SIRF/build/Testing/Temporary/LastTest.log
# may exceed 4MB travis log limit
[ "$DEBUG" != 0 ] && cat gadgetron.log

popd

exit $ret
