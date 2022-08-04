# CC SyneRBI Virtual Machine: Build your own VM 

This folder contains a series of files and scripts to create and install a virtual machine running [SIRF](https://github.com/SyneRBI/SIRF) and its prerequisites. If you just want to download and use a pre-built VM, it can be downloaded from our [website](http://www.ccpsynerbi.ac.uk/downloads), just check the
[installation  instructions](INSTALL.md) and our [documentation](documentation/RAEDME.md)
for basic usage.

The remainder of this file documents how to build your own VM.
## Prerequisites for machine creation

To create a new VM yourself, you need to have both [Vagrant](https://www.vagrantup.com) and [Virtual Box](https://www.virtualbox.org) installed on your machine.

## Machine creation

Clone our repository and launch vagrant in the vagrant directory. In windows you should be running something like MinGW terminal, not the windows command line.

    vagrant plugin install vagrant-vbguest
    vagrant up
	
The pre-built Ubuntu machine is downloaded and then configured. Virtual Box should be launched and you should see it appearing. After this first phase you should be able to launch 

    vagrant provision

That will finish up the creation steps. 

Refer to [here](https://github.com/SyneRBI/SyneRBI_VM/blob/master/INSTALL.md) for further informations and instructions.

## Pre-built downloads
A pre-built VM with SIRF installed is currently available at [www.ccpsynerbi.ac.uk/downloads](www.ccpsynerbi.ac.uk/downloads). The page states which version of VirtualBox was used to create it. 

### Pre-built VM final steps
When building the official prebuilt VM with SIRF pre-installed, we follow the steps above. 
Additionally we run the script `first_run.sh` which

1. changes some settings of the gnome desktop environment
2. compacts the size of the appliance. This step involves filling the virtual hard drive with an enormous file followed by its removal.

Users are **not required** to run the `first_run.sh` script. However, you then probably want to run the `configure_gnome.sh`script
which does the gnome configuration.

### Notes on CUDA

Although this does not apply to the VirtualBox VM, these scripts are being used to create VM on the cloud. 
We found that the appropriate CUDA toolkit to install is 10.1, by following [these](https://github.com/SyneRBI/SIRF-SuperBuild/issues/273) instructions:

#### Uninstall CUDA

    sudo /usr/local/cuda-X.Y/bin/uninstall_cuda_X.Y.pl
    sudo /usr/bin/nvidia-uninstall
    sudo apt-get --purge remove nvidia*
    sudo apt-get --purge remove cuda*
    sudo rm -r /usr/local/cuda-X
    sudo reboot
    
#### Install CUDA 10.1

    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin
    sudo mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600
    wget https://developer.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda-repo-ubuntu1804-10-1-local-10.1.168-418.67_1.0-1_amd64.deb
    sudo dpkg -i cuda-repo-ubuntu1804-10-1-local-10.1.168-418.67_1.0-1_amd64.deb
    sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
    sudo apt-get update
    sudo apt-get install cuda
    sudo reboot
 
