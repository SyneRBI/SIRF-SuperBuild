#!/usr/bin/env bash

## Usage:
# service.multi.sh [<NUM_INST> [<MIN_PORT>]]
#
# Arguments:
#   <NUM_INST>  : [default: 10]
#   <MIN_PORT>  : [default: 8890]
##

[ -f .bashrc ] && . .bashrc
this=$(dirname "${BASH_SOURCE[0]}")
NUM_INST="${1:-10}"
MIN_PORT="${2:-8890}"
INSTALL_DIR=/devel

stop_service()
{
  echo "stopping jobs"
  for i in $(jobs -p); do kill -n 15 $i; done 2>/dev/null
  exit 0
}

for JUPYTER_PORT in `seq $MIN_PORT $[MIN_PORT + NUM_INST - 1]`; do
  [ -d $INSTALL_DIR/SIRF-Exercises-$JUPYTER_PORT ] \
    || cp -r $INSTALL_DIR/SIRF-Exercises $INSTALL_DIR/SIRF-Exercises-$JUPYTER_PORT
  jupyter lab --ip 0.0.0.0 --port $JUPYTER_PORT \
    --no-browser --notebook-dir $INSTALL_DIR/SIRF-Exercises-$JUPYTER_PORT &
done

trap "stop_service" SIGTERM
trap "stop_service" SIGINT
wait
