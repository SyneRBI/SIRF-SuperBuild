#!/bin/bash
# Exit if something goes wrong
set -e
trap 'echo An error occurred in $0 at line $LINENO. Current working-dir: $PWD' ERR

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

if [ ! -d $INSTALL_DIR ]
then
  # create it in a very dangerous fashion
  # This is hopefully ok as we know what the history was of the VM.
  # We will need to fix this when we create a new VM.
  cd /home/stir/devel/build
  sudo rm -r -f *
  mkdir install
  mkdir install/bin
fi

cd $SRC_PATH/ismrmrd
git pull
cd $BUILD_PATH
if [ ! -d ismrmrd ]
then
  mkdir ismrmrd
  cd ismrmrd
  $CMAKE $SRC_PATH/ismrmrd
else
  cd ismrmrd
  $CMAKE .
fi
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
  cd STIR  
  $CMAKE -DGRAPHICS=None -DBUILD_EXECUTABLES=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON $SRC_PATH/STIR
else
  cd STIR
  $CMAKE .
fi
make install

cd $SRC_PATH/gadgetron
git pull
cd $BUILD_PATH
if [ ! -d gadgetron ]
then
  mkdir gadgetron
  cd gadgetron
  $CMAKE $SRC_PATH/gadgetron
else
  cd gadgetron
  $CMAKE .
fi
make install

cd $SRC_PATH
if [ -d SIRF ]
then
  cd SIRF
  git pull
  git submodule update --init
else
  git clone --recursive https://github.com/CCPPETMR/SIRF
fi
cd $BUILD_PATH
if [ ! -d SIRF ]
then
  mkdir SIRF
  cd SIRF
  $CMAKE $SRC_PATH/SIRF
else
  cd SIRF
  $CMAKE .
fi
make install

# update STIR-exercises if it was installed
if [ -d ~/STIR-exercises ]
then
    cd ~/STIR-exercises
    git pull
fi


# copy scripts into the path
cp -vp $SRC_PATH/CCPPETMR_VM/scripts/update*sh $INSTALL_DIR/bin
# check if the directory is in the path
if type update_VM_to_full_STIR.sh >/dev/null 2>&1
then
  : # ok
else
    echo "PATH=\$PATH:$INSTALL_DIR/bin" >> ~/.bashrc
    echo "Close your terminal and re-open a new one to update your path, or type"
    echo "PATH=\$PATH:$INSTALL_DIR/bin" 
fi

# Clean-up of old code
cd ~/devel
if [ -d xGadgetron ]
then
  rm -r -f xGadgetron
fi
if [ -d xSTIR ]
then
  rm -r -f xSTIR
fi
if [ -d iUtilities ]
then
  rm -r -f iUtilities
fi

