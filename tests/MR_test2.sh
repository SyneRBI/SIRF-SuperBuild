#! /bin/sh

# check if Gadgetron is running
a=`ps aux | grep '[g]adgetron'`
if [ ${#a} -gt 0 ] 
then
  PID=`echo $a | gawk '{print $2}'`
  echo "Gadgetron is running with PID $PID" 
else
  echo "Gadgetron is not running"
  #echo "Launching Gadgetron"
  #gadgetron &
  exit -1
fi

# Start test SIRF/src/xGadgetron/pGadgetron/tests/undersampled.py
python SIRF/src/xGadgetron/pGadgetron/tests/undersampled.py

# exit with last exit status
exit_status=$?
if [ $? -eq 0 ] 
then 
  echo "ALL PASSED"
  #exit_status=0
else
  echo "FAILED"
fi
exit $exit_status
