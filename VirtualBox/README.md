# CCP SyneRBI Virtual Machine 

This folder contains a series of files and scripts to create and install a virtual machine running [SIRF](https://github.com/SyneRBI/SIRF) and its prerequisites. 

## Downloading a pre-build VM
If you just want to download and use a pre-built VM, it can be downloaded from our [website](http://www.ccpsynerbi.ac.uk/downloads).
Check the [installation instructions](INSTALL.md).

## Using the VM
Check the [documentation](documentation/README.md) for basic usage.

## Machine creation
Check [vagrant/README.md](vagrant/README.md) for how to create a VM using Vagrant.

## Notes on CUDA

Although this does not apply to the VirtualBox VM, these scripts are being used to create VM on the cloud. 
We found that the appropriate CUDA toolkit to install is 10.1, by following [these](https://github.com/SyneRBI/SIRF-SuperBuild/issues/273) instructions:

### Uninstall CUDA

    sudo /usr/local/cuda-X.Y/bin/uninstall_cuda_X.Y.pl
    sudo /usr/bin/nvidia-uninstall
    sudo apt-get --purge remove nvidia*
    sudo apt-get --purge remove cuda*
    sudo rm -r /usr/local/cuda-X
    sudo reboot
    
### Install CUDA 10.1

    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin
    sudo mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600
    wget https://developer.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda-repo-ubuntu1804-10-1-local-10.1.168-418.67_1.0-1_amd64.deb
    sudo dpkg -i cuda-repo-ubuntu1804-10-1-local-10.1.168-418.67_1.0-1_amd64.deb
    sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
    sudo apt-get update
    sudo apt-get install cuda
    sudo reboot
 
