You can use CCPPETMR Virtual Machine as a Gadgetron server if you cannot install Gadgetron on you computer (we ourselves have not yet succeeded in installing it under Windows). This can be done using port forwarding. For this, you need to set up communication between your computer and VM in the following manner.

* Start Virtual Machine.

* For a VM prior to v2.0.0, forward port 9002 to VM (in Oracle VM VirtualBox Manager: go to Settings->Network, click on Port Forwarding, add new forwarding rule by clicking on +, set Host Port and Guest Port to 9002). (Since 2.0.0, this has already be done for you).

* Open a new Linux terminal on VM and type 'gadgetron' there.

This will enable you to run SIRF MR demos on your computer.

An [alternative solution](https://github.com/CCPPETMR/SIRF/wiki/SIRF-SuperBuild-on-Docker) is to use docker.