#!/bin/bash

sudo apt-get install python-scipy python-docopt python-matplotlib

source ~/.bashrc

if [ -z $INSTALL_DIR ]
then
  export INSTALL_DIR=/home/stir/devel/build/install
  echo 'export INSTALL_DIR=/home/stir/devel/build/install' >> ~/.bashrc
  export LD_LIBRARY_PATH=$INSTALL_DIR/lib:$LD_LIBRARY_PATH
  echo 'export LD_LIBRARY_PATH=$INSTALL_DIR/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
  export PYTHONPATH=$INSTALL_DIR/python
  echo 'export PYTHONPATH=$INSTALL_DIR/python' >> ~/.bashrc
  export CMAKE="cmake -DCMAKE_PREFIX_PATH:PATH=$INSTALL_DIR/lib/cmake -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_DIR"
  echo 'export CMAKE="cmake -DCMAKE_PREFIX_PATH:PATH=$INSTALL_DIR/lib/cmake -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_DIR"' >> ~/.bashrc
  export CCMAKE="ccmake -DCMAKE_PREFIX_PATH:PATH=$INSTALL_DIR/lib/cmake -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_DIR"
  echo 'export CCMAKE="ccmake -DCMAKE_PREFIX_PATH:PATH=$INSTALL_DIR/lib/cmake -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_DIR"' >> ~/.bashrc
fi

if [ ! -d /home/stir/devel/build/install ]
then
  cd /home/stir/devel/build
  sudo rm -r -f *
  mkdir install
fi

cd $SRC_PATH/ismrmrd
git pull
cd $BUILD_PATH
if [ ! -d ismrmrd ]
then
  mkdir ismrmrd
fi
cd ismrmrd
$CMAKE $SRC_PATH/ismrmrd
make install

cd $SRC_PATH
if [ -d ismrmrd-python-tools ]
then
  cd ismrmrd-python-tools
  git pull
else
  git clone https://github.com/CCPPETMR/ismrmrd-python-tools
  cd ismrmrd-python-tools
fi
sudo python setup.py install

cd $SRC_PATH/STIR
git pull
cd $BUILD_PATH
if [ ! -d STIR ]
then
  mkdir STIR
fi
cd STIR
$CMAKE -DGRAPHICS=None -DBUILD_EXECUTABLES=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON $SRC_PATH/STIR
make install

cd $SRC_PATH/gadgetron
git pull
cd $BUILD_PATH
if [ ! -d gadgetron ]
then
  mkdir gadgetron
fi
cd gadgetron
$CMAKE $SRC_PATH/gadgetron
make install

cd $SRC_PATH
if [ -d SIRF ]
then
  cd SIRF
  git pull
  git submodule update
else
  git clone --recursive https://github.com/CCPPETMR/SIRF
fi
cd $BUILD_PATH
if [ ! -d SIRF ]
then
  mkdir SIRF
fi
cd SIRF
$CMAKE $SRC_PATH/SIRF
make install

cd ~/devel
if [ -d xGadgetron ]
then
  rm -r xGadgetron
fi
if [ -d xSTIR ]
then
  rm -r xSTIR
fi

