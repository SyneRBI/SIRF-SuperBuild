#! /bin/sh

# Start test SIRF/src/xSTIR/pSTIR/tests/test1.py
python SIRF/src/xSTIR/pSTIR/tests/test1.py

# exit with last exit status
exit_status=$?
if [ $? -eq 0 ] 
then 
  echo "ALL PASSED"
else
  echo "FAILED"
fi
exit $exit_status
