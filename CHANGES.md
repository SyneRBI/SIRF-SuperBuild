# ChangeLog

# 3.0.0
- build with python3
- add update_VM_to_full_CIL.sh script to use `BUILD_CIL=ON` in SuperBuild

# 2.2.0

- handle rename of project CCPPETMR->SyneRBI
- add option to update system prerequisites with update_VM.sh

## 2.1.0

- added CIL prerequisites. 

## 2.0.1
- remove spyder-kernels

## 2.0.0
- upgraded to Ubuntu 18.04
- installs more recent Gadgetron https://github.com/gadgetron/gadgetron/commit/b6191eaaa72ccca6c6a5fe4c0fa3319694f512ab
- add port forwarding (8888 -> 8888 for jupyter and 9001 and 9002 for Gadgetron)
- install jupyter notebook, with default password 'virtual'
- installs spyder v3.2
- does not install a browser
- add cython for CIL


## 1.1.1
- added nbstripout (https://github.com/kynan/nbstripout) to handle conflicts in SIRF-Exercises

## 1.1.0
- added pip, firefox 
- added spyder and jupyer via pip
- Virtual Machine is built with Virtual Box 5.2.12

## v1.0.0
- Creation of VM is automated by a vagrant script, and a `first_run.sh` script to execute after the VM is up for the first time
- `update_VM.sh` will now by default update to the latest release (of the SuperBuild). Options have been added to modify this.
- updated base box to ubuntu-xenial64
- Virtual Machine is built with Virtual Box 5.2.8

## v0.9.2
- fixes to update script

## v0.9.1
-  Use SuperBuild as update mechanism
