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
[ -f ./INSTALL/bin/gadgetron ] && ./INSTALL/bin/gadgetron >& gadgetron.log&
#sudo sysctl net.ipv4.ip_forward=1
#sudo apt install -yqq iptables
#sudo iptables -t nat -A PREROUTING -p tcp --dport 9002 -j DNAT --to-destination 172.18.0.2:9002
#sudo iptables -t nat -A POSTROUTING -j MASQUERADE
pushd $SIRF_PATH/src/xGadgetron/pGadgetron/tests
python test_all.py
popd

ctest -VV
ret=$?
[ -n "$(pidof gadgetron)" ] && kill -n 15 $(pidof gadgetron)

# print for debugging
[ "$DEBUG" != 0 ] && cat builds/SIRF/build/CMakeCache.txt
[ "$DEBUG" != 0 ] && cat builds/SIRF/build/Testing/Temporary/LastTest.log
# may exceed 4MB travis log limit
[ "$DEBUG" != 0 ] && [ -f gadgetron.log ] && cat gadgetron.log

popd

exit $ret
