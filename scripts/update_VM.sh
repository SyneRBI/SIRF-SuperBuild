#!/bin/sh

echo "Updating..."
SIRF_TAG="default"
while getopts :t: option
 do
 case "${option}"
  in
  t) SIRF_TAG=$OPTARG;;
 esac
done


cd ~/devel/CCPPETMR_VM
git pull
cd scripts

if [ $SIRF_TAG = 'default' ] 
then
  ./UPDATE.sh
else
 ./UPDATE.sh -t $SIRF_TAG
fi

echo "All done"
