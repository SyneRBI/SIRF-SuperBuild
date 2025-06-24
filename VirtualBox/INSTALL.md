# SyneRBI Virtual Machine: Installation and running of pre-built machine

A pre-built VM can be downloaded from this [Zenodo page](https://zenodo.org/records/10887535). Here we explain
how to install it, once downloaded. (If you want to build a new VM yourself, then check the [vagrant/README.md](vagrant/README.md) for instructions.)

For macOS systems with Apple Silicon (ARM64), follow the dedicated section below.

## Initial download and installation


1. Make sure you have enough free disk-space on your laptop (~10GB for installation).

2. Install VirtualBox (VB). Please note that this will require administrator permissions on your computer. The "host" operating system refers to your computer. 
You do not need to install the Oracle extensions to VirtualBox, although it might come in handy for USB support. 
Although other Virtual Machine software might work, we have not tried this and will not be able to help to get this going.
    
   For Macs, the installation of Virtual Box might require you to alter your security settings. 
    - If you receive an error along the lines of `kernel driver not installed (rc=-1908)`, the following might help. Click on the Apple icon in the top-left of your screen and then `System Preferences->Security & Privacy->General`. Click the padlock in the bottom-left and enter your password to be able to make changes to this page. Click `Allow` next to the Virtual Box text. Hopefully the problem will have been sorted.
    - If the installation takes you directly to the `Security and Privacy` window, select `Allow` (the VB is labelled as from Oracle). When the installer asks if it should Move to Trash, say `Keep` because you need to re-run the installation again with this revised security setting. Second time around, you can move it to trash.

3. Download the preinstalled virtual machine from [Zenodo](https://doi.org/10.5281/zenodo.3552234).
Warning: this file can be ~4.9GB. (You can download to a USB stick or hard drive to save space on your hard-disk).

4. Open the downloaded OVA file (double-click or whatever is appropriate for your system). This should start VirtualBox with the "Import" dialog box.

5. Change settings of the virtual machine (you can still change this afterwards by using the Settings menu of VirtualBox). The only things that need your attention:
	- CPU: use the same number of CPUs (i.e. cores) as your laptop/desktop (or 1 less)
	- RAM: use about half the RAM of your laptop (assigning too much RAM will slow down your/desktop laptop dramatically, using not enough will slow down the virtual machine. 1.5GB seems to be enough for the basic examples though.)
	- Virtual Disk Image: normally this filename is fine but you can save it somewhere else if you like

6. If still present, tick the box "Reinitialise the MAC address of all network cards"

7. Press Import and wait for a few minutes (everything will be decompressed etc).

8. In the VirtualBox window, select your new VM and press the Settings icon. In the "General" category, "Advanced" tab, check that "Shared Clipboard" is set to "bidirectional".

## macOS(ARM64)

1. Make sure you have enough free disk-space on your laptop (~10GB for installation).
2. Make sure you have Xcode Command Line Tools installed:
```bash
xcode-select --install
```
3. Install Homebrew if not already installed:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
4. Install QEMU:
```bash
brew install qemu
```
5. Download the preinstalled virtual machine from [Zenodo](https://doi.org/10.5281/zenodo.3552234).
6. extract the .ova file and convert the disk image to .qcow2 format
```bash
tar -xvf "SIRF 3.8.1.ova"
qemu-img convert -f vmdk -O qcow2 "SIRF 3.8.1-disk002.vmdk" SIRF_3.8.1_disk.qcow2
```
7. Run the VM with QEMU:
```bash
qemu-system-x86_64 \
  -machine accel=tcg \
  -cpu Haswell \
  -m 8192 \
  -smp 4 \
  -drive file=SIRF_3.8.1_disk.qcow2,format=qcow2 \
  -net nic \
  -net user,hostfwd=tcp::8888-:8888 \
  -display cocoa \
  -vga std
```
- -m specifies the RAM size. Use about half of your laptop’s total RAM. Assigning too much RAM can slow down your host machine, while too little will slow down the virtual machine 
- -smp sets the number of CPU cores to emulate (x86_64).
- -net user,hostfwd=tcp::8888-:8888 exposes port 8888 of the VM to the host.


8. Log in and set up JupyterLab:
   
If everything works, you should see a window where Ubuntu boots. Once it has started:
- Log in with username: stiruser (password = virtual)
- Open a terminal inside the VM
- Set a password for the Jupyter server:
```bash
jupyter notebook password
```
9. Launch the jupyter server with port forwarding:
```bash
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser
```
10. Open the jupyterlab from outside the VM
- open a browser (preferably not safari) and go to [http://localhost:8888](http://localhost:8888)




		


## Usage

Check our [documentation](documentation/README.md) for usage instructions.

