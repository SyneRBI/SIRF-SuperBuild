Refer to [this page](https://www.vagrantup.com/docs/virtualbox/boxes.html) for more info.

## Virtual Machine Hardware
Creating a virtualbox base box is done by creating a new machine from the virtual box interface. 
For Vagrant there are 2 requirements:

1. The first network interface (adapter 1) must be a NAT adapter. Vagrant uses this to connect the first time.

2. The MAC address of the first network interface (the NAT adapter) should be noted, since you will need to put it in a Vagrantfile later as the value for config.vm.base_mac. To get this value, use the VirtualBox GUI.

## Virtual Machine Operating System 

The minimal software that has to be present on the VM is
1. Package manager
1. SSH
1. SSH user so Vagrant can connect

By using a Ubuntu 18.04 LTS we have access to the package manager and ssh. 
I downloaded the minimal iso for an Ubuntu 18.04 LTS from http://archive.ubuntu.com/ubuntu/dists/bionic/main/installer-amd64/current/images/netboot/
Insert the iso and boot the machine. Configure the machine. Do not install any software.

### SSH 

```bash
sudo apt-get install openssh-server
```
* One must create a user `vagrant/vagrant`
* One can use an [insecure keypair](https://www.vagrantup.com/docs/boxes/base.html#quot-vagrant-quot-user) for Vagrant to connect passwordless to the VM. This keypair will be updated to a new one. 
* The public rsa for the insecure keypair can be downloaded here https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub

```bash
mkdir .ssh
cd .ssh
wget https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub -O authorized_keys
chmod 700 .ssh
chmod 600 .ssh/authorized_keys
dd if=/dev/zero of=/tmp/EMPTY bs=1M
rm /tmp/EMPTY
```

### VirtualBox Guest Additions

It's time to add the VGA! 
https://www.vagrantup.com/docs/virtualbox/boxes.html#virtualbox-guest-additions

```bash
sudo apt-get install linux-headers-$(uname -r) build-essential dkms
mount /dev/cdrom /media
sudo sh /media/VBoxLinuxAdditions.run
reboot
```

## Package the box
Just issue 
```
vagrant package --name my-vb-box
``` 
where `my-vb-box` is the name of the VM on the VirtualBox GUI.

To test whether you've done a good job or not, you can add the box to the list of boxes Vagrant knows about. 

```
vagrant box add <name_of_the_box> package.box
```
This will allow you to launch vagrant trying to boot a basebox with name `<name_of_the_box>`.