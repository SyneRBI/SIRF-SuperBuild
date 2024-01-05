#!/usr/bin/env bash

## Usage:
# test.sh [<DEBUG_LEVEL>]
#
# Arguments:
#   <DEBUG_LEVEL>  : [default: 0]
##

DEBUG="${1:-0}"

pushd $(dirname "$(dirname "$SIRF_PATH")")

# start gadgetron
[ -f ./INSTALL/bin/gadgetron ] && ./INSTALL/bin/gadgetron >& gadgetron.log&

ctest --output-on-failure

ret=$?
[ -n "$(pidof gadgetron)" ] && kill -n 15 $(pidof gadgetron)

# print for debugging
[ "$DEBUG" != 0 ] && cat builds/SIRF/build/CMakeCache.txt
# may exceed 4MB travis log limit
[ "$DEBUG" != 0 ] && [ -f gadgetron.log ] && tail -n 500 gadgetron.log

popd

exit $ret
