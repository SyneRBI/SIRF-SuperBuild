#!/usr/bin/env bash
_help(){
cat <<EOF
Usage:
  $0 [options]

Options:
  Forwarded to start-notebook.py
  i.e. https://github.com/jupyter/docker-stacks/blob/main/images/base-notebook/start-notebook.py
  and https://github.com/jupyter/docker-stacks/blob/main/images/docker-stacks-foundation/start.sh
EOF
}

DEBUG=0
test -f .bashrc && . .bashrc

stop_service(){
  echo "stopping jobs"
  for i in $(jobs -p); do kill -n 15 $i; done 2>/dev/null

  if test "$DEBUG" != 0; then
    if test -f ~/gadgetron.log; then
      echo "----------- Last 70 lines of ~/gadgetron.log"
      tail -n 70 ~/gadgetron.log
    fi
  fi

  exit 0
}

pushd $SIRF_PATH/../..

echo "start gadgetron"
[ -f ./INSTALL/bin/gadgetron ] \
  && ./INSTALL/bin/gadgetron >& ~/gadgetron.log&

echo "make sure the SIRF-Exercises and CIL-Demos are in the expected location (~/work in the container)"
cd ~/work
for notebooks in SIRF-Exercises CIL-Demos; do
  test -d ${notebooks} || cp -a $SIRF_PATH/../../../${notebooks} .
done

echo "link SIRF-Contrib into ~/work"
if test ! -r SIRF-contrib; then
  echo "Creating link to SIRF-contrib"
  ln -s "$SIRF_INSTALL_PATH"/python/sirf/contrib SIRF-contrib
fi

echo "start jupyter"
test -w /etc/jupyter/jupyter_server_config.py \
  && echo "c.ServerApp.password = u'sha1:cbf03843d2bb:8729d2fbec60cacf6485758752789cd9989e756c'" \
  >> /etc/jupyter/jupyter_server_config.py
start-notebook.py "$@"

popd

trap "stop_service" EXIT INT TERM
wait
