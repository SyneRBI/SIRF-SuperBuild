# Building SyneRBI_VM via Vagrant

## Installation

- Install VirtualBox
- Install [Vagrant](https://www.vagrantup.com)

## Vagrant commands
- Make sure there is no other SIRF VM running (as it will mean vagrant aborts due to a port forwarding conflict)

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

## Documentation

- [https://www.vagrantup.com/docs/](https://www.vagrantup.com/docs/)
- [https://www.packer.io/intro/](https://www.packer.io/intro/)
