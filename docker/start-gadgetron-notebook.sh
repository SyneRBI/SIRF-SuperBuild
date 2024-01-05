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

SB_PATH=$(dirname "$(dirname "$SIRF_PATH")")
echo "start gadgetron"
pushd "${SB_PATH}"
test -x ./INSTALL/bin/gadgetron && ./INSTALL/bin/gadgetron >& ~/gadgetron.log&
popd

echo "make sure the SIRF-Exercises and CIL-Demos are in the expected location (~/work in the container)"
pushd ~/work
for notebooks in SIRF-Exercises CIL-Demos; do
  test -d ${notebooks} || cp -a "${SB_PATH}/../${notebooks}" .
done

echo "link SIRF-Contrib into ~/work"
if test ! -r SIRF-contrib; then
  echo "Creating link to SIRF-contrib"
  ln -s "${SIRF_INSTALL_PATH}/python/sirf/contrib" SIRF-contrib
fi
popd

echo "start jupyter"
start-notebook.py \
  --PasswordIdentityProvider.hashed_password='sha1:cbf03843d2bb:8729d2fbec60cacf6485758752789cd9989e756c' \
  "$@"

trap "stop_service" EXIT INT TERM
wait
