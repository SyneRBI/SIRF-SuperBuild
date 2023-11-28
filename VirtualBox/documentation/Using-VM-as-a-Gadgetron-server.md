You can use the SyneRBI Virtual Machine as a Gadgetron server if you cannot install Gadgetron on your computer (we ourselves have not yet succeeded in installing it under Windows). This could be useful if you want to run SIRF (or or other Gadgetron clients) on your computer (as opposed to in the VM).

* Start Virtual Machine.

* For a VM prior to v2.0.0, forward port 9002 to VM (in Oracle VM VirtualBox Manager: go to Settings->Network, click on Port Forwarding, add new forwarding rule by clicking on +, set Host Port and Guest Port to 9002). (Since 2.0.0, this has already be done for you).

* Open a new Linux terminal on VM and type 'gadgetron' there.

An [alternative solution](https://github.com/SyneRBI/SIRF-SuperBuild/tree/master/docker/README.md) is to use docker.
