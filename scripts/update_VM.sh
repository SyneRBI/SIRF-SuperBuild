#!/bin/sh

echo "Updating..."
cd ~/devel/SyneRBI_VM
git pull
cd scripts

./UPDATE.sh $*

echo "All done"
