#!/bin/sh

echo "Updating..."

cd ~/devel/CCPPETMR_VM
git pull
cd scripts
./UPDATE.sh

echo "All done"
