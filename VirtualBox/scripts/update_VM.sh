#!/bin/sh

echo "Updating..."
cd ~/devel/SIRF-SuperBuild/VirtualBox
git pull
cd scripts

./UPDATE.sh $*

echo "All done"
