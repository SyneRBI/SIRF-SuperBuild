#! /bin/bash
# source env 
export INSTALL_DIR=~/install
source ${INSTALL_DIR}/bin/env_sirf.sh

# append the path of virtualenv
export PATH=~/.local/bin:$PATH
source ~/virtualenv/bin/activate 

gadgetron >& gadgetron.log&
# print for debugging
cat $GITHUB_WORKSPACE/build/builds/SIRF/build/CMakeCache.txt
cd $GITHUB_WORKSPACE/build
ctest --output-on-failure; test_fail=$?
# echo "----------- Killing gadgetron server"
# killall gadgetron
if [[ $test_fail -ne 0 ]]; then
 #echo "----------- Test output"
 # cat builds/SIRF/build/Testing/Temporary/LastTest.log
 echo "----------- Last 70 lines of gadgetron.log"
 tail -n 70 gadgetron.log
fi
exit $test_fail
