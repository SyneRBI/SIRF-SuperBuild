# Building SyneRBI_VM via Vagrant

## Installation

- Install VirtualBox
- Install [Vagrant](https://www.vagrantup.com)

## Vagrant commands

- Start the machine

```
cd vagrant
vagrant up
```

- Pause the machine

```
vagrant suspend
```

- Shutdown the machine

```
vagrant halt
```

- Remove the machine (to start from scratch)

```
vagrant destroy
```

## Notes about ubuntu box for version 1.0.0

The current ubuntu box the VM is based on is `ubuntu/xenial64`. The installed `grub` requires a serial port to be attached, see [here](https://github.com/SyneRBI/SyneRBI_VM/issues/58). This appliance contains an hard coded link to a file on the machine which has exported it, and the VM cannot be shared.

To be able to distribute the VM it is important to remove such hard coded link. After the creation of the VM, we 

1. [remove](https://github.com/SyneRBI/SyneRBI_VM/blob/master/vagrant/Vagrantfile#L101) the serial port from the grub configuration.
2. Manually deselect the serial port from the machine settings.

## Documentation

- [https://www.vagrantup.com/docs/](https://www.vagrantup.com/docs/)
- [https://www.packer.io/intro/](https://www.packer.io/intro/)
