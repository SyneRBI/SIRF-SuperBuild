# Using the VM as server

As of SIRF 2.0.0 we enable [port forwarding](https://github.com/CCPPETMR/CCPPETMR_VM/blob/master/vagrant/Vagrantfile#L36L38) on 
the VM by default:

| Service | Host Port | Guest Port | Protocol |
|---------|-----------|------------|----------|
| jupyter notebook | 8888 | 8888 | TCP/IP |
| Gadgetron | 9001 | 9001 | TCP/IP |
| Gadgetron | 9002 | 9002 | TCP/IP |

## Gadgetron server
You can use SyneRBI Virtual Machine as a Gadgetron server if you cannot install Gadgetron on you computer (we ourselves have not yet succeeded in installing it under Windows).

1. Start Virtual Machine.
1. Open a new terminal on the VM and type `gadgetron` there.
1. Keep the VM running and run Python or Matlab on your normal computer.

This will enable you to run SIRF MR demos on your computer.

## Jupyter Notebook

A [jupyter notebook](https://jupyter.org/) server is installed in the VM it can be started as:

1. open a terminal in the VM
2. type `jupyter lab`
3. in the host, open a browser and point to `http://127.0.0.1:8888`
4. (optional) you may need to start Gadgetron, as above
