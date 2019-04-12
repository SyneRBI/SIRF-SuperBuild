# CCPPETMR Virtual Machine: Build your own VM 

This project contains a series of files and scripts to create and install a virtual machine running [SIRF](https://github.com/CCPPETMR/SIRF) and its prerequisites. If you just want to download and use a pre-built VM, it can be downloaded from our [website](http://www.ccppetmr.ac.uk/downloads), just check the
[installation  instructions](INSTALL.md) and our [wiki](https://github.com/CCPPETMR/CCPPETMR_VM/wiki)
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

Refer to [here](https://github.com/CCPPETMR/CCPPETMR_VM/blob/master/INSTALL.md) for further informations and instructions.

## Pre-built downloads
A pre-built VM with SIRF installed is currently available at [www.ccppetmr.ac.uk/downloads](www.ccppetmr.ac.uk/downloads). The page states which version of VirtualBox was used to create it. 

### Pre-built VM final steps
When building the official prebuilt VM with SIRF pre-installed, we follow the steps above. 
Additionally we run the script `first_run.sh` which

1. changes some settings of the gnome desktop environment
2. compacts the size of the appliance. This step involves filling the virtual hard drive with an enormous file followed by its removal.

Users are **not required** to run the `first_run.sh` script. However, you then probably want to run the `configure_gnome.sh`script
which does the gnome configuration.

