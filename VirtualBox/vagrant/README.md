# Building SyneRBI_VM via Vagrant

## Installation of prerequisites

- Install VirtualBox
- Install [Vagrant](https://www.vagrantup.com)
- Install the vbguest plugin. This makes sure the VirtualBox Guest additions will be up-to-date w.r.t.
the VirtualBox version you have.
```
vagrant plugin install vagrant-vbguest
```

## VM creation

Make sure there is no other SIRF VM running (as it will mean vagrant aborts due to a port forwarding conflict)

### Start the machine

```
cd vagrant
vagrant up
```
This will take a substantial amount of time.

### Final configuration
Log into the VM, open a terminal and type
```sh
~/devel/SIRF-SuperBuild/VirtualBox/scripts/first_run.sh
```
1. changes some settings of the gnome desktop environment
2. configures Jupyter
3. compacts the size of the appliance. This step involves filling the virtual hard drive with an enormous file followed by its removal.

In fact, if you do not intend to export the VM, you could skip the `zero_fill.sh` step.

## Other useful vagrant commands
The following can be done via the VirtualBox interface, but you can use `vagrant` as well.

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

## Documentation

- [https://www.vagrantup.com/docs/](https://www.vagrantup.com/docs/)
- [https://www.packer.io/intro/](https://www.packer.io/intro/)
