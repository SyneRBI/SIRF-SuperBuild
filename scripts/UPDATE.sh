#!/bin/sh

sudo apt-get install python-scipy

cd ~/devel/iUtilities
git pull 
make clean 
make

cd ~/devel/xSTIR
git pull
cd cSTIR
make
cd ../pSTIR
make

cd ~/devel/xGadgetron
git pull
cd cGadgetron
make clean 
make
cd ../pGadgetron
make clean
make
cd ../examples
make

cd ~/devel/CCPPETMR_VM
cp HELP.txt ~/Desktop
