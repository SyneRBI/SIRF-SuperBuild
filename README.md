# CCPPETMR Virtual Machine 

This projects contains as series of scripts to create and install a virtual machine running SIRF and its prerequisites. 

If instead, you are trying to find information on how to use the virtual machine that can be downloaded from our [website](http://www.ccppetmr.ac.uk/downloads) just check [here]()

## Prerequisites

To proceed with this you need to have installed on your machine both [Vagrant](https://www.vagrantup.com) and [Virtual Box](https://www.virtualbox.org).

## Machine creation

Clone our repository and launch vagrant in the vagrant directory. In windows you should be running something like MinGW terminal, not the windows command line.

    vagrant up
	
The machine is pulled and built. Virtual Box should be launched and you should see it appearing. After this first phase you should be able to launch 

    vagrant provision
	
That will finish up the creation steps. 

Now you created your VM! It's time to update it. Start the VM and open a terminal (click on activities and type xterm). Issue the following commands 

    update_VM.sh
	sudo /home/sirfuser/devel/CCPPETMR_VM/scripts/update_VGA.sh
	
Refer to [here]() for further informations and instructions.

The VM you created is very very bare and a better UI should be installed. To keep disk occupancy low we suggest to run

    sudo apt-get install at-spi2-core gnome-terminal gnome-control-center nautilus
	
which will give a minimal UI usability with low disk occupancy.