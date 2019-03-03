#!/usr/bin/env bash

## Usage:
# test.sh [<DEBUG_LEVEL> [<JUPYTER_PORT>]]
#
# Arguments:
#   <DEBUG_LEVEL>  : [default: 0]
#   <JUPYTER_PORT>  : [default: 8888]
##

DEBUG="${1:-0}"
JUPYTER_PORT="${2:-8888}"
this=$(dirname "${BASH_SOURCE[0]}")

stop_service()
{
  echo "stopping jobs"
  for i in $(jobs -p); do kill -n 15 $i; done 2>/dev/null

  if [ "$DEBUG" != 0 ]; then
    if [ -f gadgetron.log ]; then
      echo "----------- Last 70 lines of gadgetron.log"
      tail -n 70 gadgetron.log
    fi
  fi

  exit 0
}

pushd $SIRF_PATH/../..

# start gadgetron
GCONFIG=./INSTALL/share/gadgetron/config/gadgetron.xml
[ -f "$GCONFIG" ] || cp "$GCONFIG".example "$GCONFIG"
[ -f ./INSTALL/bin/gadgetron ] && ./INSTALL/bin/gadgetron >& gadgetron.log&

# start jupyter
pushd /devel
jupyter notebook --ip 0.0.0.0 --port $JUPYTER_PORT --no-browser &
popd

popd

trap "stop_service" SIGTERM
trap "stop_service" SIGINT
wait
