pushd /opt/SIRF-SuperBuild
test -x ./INSTALL/bin/gadgetron && ./INSTALL/bin/gadgetron >& ~/gadgetron.log&
popd
