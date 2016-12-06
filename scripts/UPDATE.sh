#!/bin/sh

TMP=virtual

echo $TMP | sudo -S apt-get install python-scipy python-docopt

cd ~/devel/ismrmrd
git pull
cd build
make
echo $TMP | sudo -S make install

cd ~/devel/gadgetron
git pull
cd build
make
echo $TMP | sudo -S make install

cd ~/devel/iUtilities
git pull 
make clean 
make

cd ~/devel/xGadgetron
git checkout master
git pull
cd cGadgetron
make clean 
make -f Makefile_VM
cd ../pGadgetron
make clean
make
cd ../examples
make

cd ~/devel/STIR
git pull
cd build
make
echo $TMP | sudo -S make install

cd ~/devel/xSTIR
git checkout master
git pull
cd cSTIR
make
cd ../pSTIR
make

cd ~/devel/CCPPETMR_VM
cp HELP.txt ~/Desktop
