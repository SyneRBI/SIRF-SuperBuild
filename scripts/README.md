
## first_run.sh

the `first_run.sh` script is used by the CCPPETMR team during the creation of the official VirtualBox VM
to 

 1. change a few settings of the gnome desktop environment and to 
 2. compact the size of the appliance. 

The latter is achieved by first filling the hard drive of the VM with a file full of zeroes and then removing it. 
If you happen to run this file you will see an error message saying that there is not space left on the device.
