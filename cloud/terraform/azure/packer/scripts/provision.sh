#!/bin/bash

NOCORES=`nproc`
echo Using $NOCORES cores

sudo apt-get update
sudo apt-get -y upgrade 

mkdir ~/devel
cd ~/devel

git clone --branch symposium2019 https://github.com/SyneRBI/SyneRBI_VM.git

cd SyneRBI_VM
sudo bash scripts/INSTALL_prerequisites_with_apt-get.sh
sudo bash scripts/INSTALL_python_packages.sh
sudo apt-get purge cmake -y
sudo bash scripts/INSTALL_CMake.sh

cd ~/devel/SyneRBI_VM
bash scripts/UPDATE.sh -j `nproc` -t origin/master
bash scripts/update_VM.sh -j `nproc` -t origin/master

cd ~/devel/SIRF-Exercises/scripts
bash download_PET_data.sh
bash download_MR_data.sh
