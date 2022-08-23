
## first_run.sh

the `first_run.sh` script is used by the SyneRBI team after the creation of the official VirtualBox VM
to 

 1. change a few settings of the gnome desktop environment and to 
 2. configure jupyter

You would run this yourself when building via `vagrant`.

## clean_before_VM_export.sh

This script is used by the SyneRBI team after the creation of the official VirtualBox VM and before exporting to OVA (or similar) to make the exported file smaller.

Steps:

1. `rm_build_files.sh` removes files that were used to build SIRF etc, but
are not necessary for running it.

2. `zero_fill.sh` fills the hard drive of the VM with a file full of zeroes and then removing it. 
If you happen to run this file you will see an error message saying that there is not space left on the device.
