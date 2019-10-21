#!/bin/bash

# Pre-requisites
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y build-essential cmake unzip pkg-config wget unzip
sudo apt-get install -y libxmu-dev libxi-dev libglu1-mesa libglu1-mesa-dev
sudo apt-get install -y libjpeg-dev libpng-dev libtiff-dev
sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
sudo apt-get install -y libxvidcore-dev libx264-dev
sudo apt-get install -y libgtk-3-dev
sudo apt-get install -y libopenblas-dev libatlas-base-dev liblapack-dev gfortran
sudo apt-get install -y libhdf5-serial-dev
sudo apt-get install -y python3-dev python3-tk python-imaging-tk python-pip

# Install CUDA toolkit 
cd ~/
wget https://developer.nvidia.com/compute/cuda/10.0/Prod/local_installers/cuda_10.0.130_410.48_linux
chmod +x cuda_10.0.130_410.48_linux
sudo ./cuda_10.0.130_410.48_linux --silent

# Add to path
touch ~/.bashrc
echo "export PATH=/usr/local/cuda-10.0/bin:$PATH" >> ~/.bashrc
if [[ -z "$LD_LIBRARY_PATH" ]]
then
    echo "export LD_LIBRARY_PATH=/usr/local/cuda-10.0/lib64:/usr/local/cuda-10.0/extras/CUPTI/lib64" >> ~/.bashrc
else
    echo "export LD_LIBRARY_PATH=/usr/local/cuda-10.0/lib64:/usr/local/cuda-10.0/extras/CUPTI/lib64:$LD_LIBRARY_PATH" >> ~/.bashrc
fi

source ~/.bashrc

## cuDNN

# Get cuDNN from site
cd ~/
wget https://ccphackathon.blob.core.windows.net/cuda/cudnn-10.0-linux-x64-v7.6.1.34.tgz
tar xvzf cudnn-10.0-linux-x64-v7.6.1.34.tgz
cd cuda
sudo cp -P lib64/* /usr/local/cuda/lib64/
sudo cp -P include/* /usr/local/cuda/include/

# File clean up
cd ~/
rm cuda_10.0.130_410.48_linux
rm cudnn-10.0-linux-x64-v7.6.1.34.tgz

# Config. xorg
sudo nvidia-xconfig

# Install tensorflow and Keras
pip install tensorflow-gpu==1.14
pip install keras