#!/bin/sh

#cd ~/devel/gadgetron
#git pull
#cd build
#make
#make install

#cd ~/devel/STIR
#git pull
#cd ../build/STIR
#make
#make install

cd ~/devel/xSTIR
git pull
cd cSTIR
make
cd ../pSTIR
make

cd ~/devel/iUtilities
git pull 
make clean 
make

cd ../xGadgetron
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
