#!/bin/sh

TMP=virtual

sudo apt-get install python-scipy python-docopt python-matplotlib

cd ~/devel/ismrmrd
git pull
cd build
make
echo $TMP | sudo -S make install

cd ~/devel
if [ -d ismrmrd-python-tools ]; then
  cd ismrmrd-python-tools/
  git pull
else
  git clone  https://github.com/CCPPETMR/ismrmrd-python-tools
  cd ismrmrd-python-tools/
fi

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
git pull
git checkout master
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
git pull
git checkout master
cd cSTIR
make
cd ../pSTIR
make

cd ~/devel/CCPPETMR_VM
cp HELP.txt ~/Desktop
