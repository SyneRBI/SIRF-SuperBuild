
# download the SIRF-Exercises data
pushd /devel
[ -d SIRF-Exercises ] || cp -a $SIRF_PATH/../../../SIRF-Exercises .
which unzip || sudo apt-get install -yqq unzip
for i in SIRF-Exercises/scripts/download_*.sh; do ./$i $PWD; done
popd
