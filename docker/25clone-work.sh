if test $UID -eq 0; then
  sudo --preserve-env --set-home --user "$NB_USER" "$0" "$@"
  exit $?
fi
pushd ~/work
for repo in SIRF-Exercises CIL-Demos; do
  test -d ${repo} || cp -dR "${SB_PATH}/../${repo}" .
done
./SIRF-Exercises/scripts/download_data.sh ${SIRF_DOWNLOAD_DATA_ARGS:-}

echo "link SIRF-Contrib into ~/work"
if test ! -r SIRF-contrib; then
  echo "Creating link to SIRF-contrib"
  ln -s "${SIRF_INSTALL_PATH}/python/sirf/contrib" SIRF-contrib
fi
popd
