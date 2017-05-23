# CCPPETMR Virtual Machine installation and running instructions

If you have any problems, please first re-check this web-page. If you cannot solve your issue, please email CCP-PETMR-USERS @ JISCMAIL.AC.UK


## Initial download and installation

1. Make sure you have enough free disk-space on your laptop (~10GB for installation).

2. Install [VirtualBox](https://www.virtualbox.org). Please note that this will require administrator permissions. 
You do not need to install the Oracle extensions to VirtualBox, although it might come in handy for USB support. 
Although other Virtual Machine software might work, we have not tried this and will not be able to help to get this going. 
Nikos Efthimiou says that if you run Ubuntu (or similar) on your laptop, VirtualBox might not install, unless you first upgrade to libvpx > 1. You could try the following (but you might want to read-up on this first):
	- wget http://launchpadlibrarian.net/199480915/libvpx1\_1.3.0-3ubuntu1\_amd64.deb
	- sudo dpkg -i libvpx1*.deb

3. Download the preinstalled virtual machine from http://www.ccppetmr.ac.uk/downloads.
Warning: this file is ~1.6GB. (You can of course download to a USB stick to save space on your hard-disk).

4. Open the downloaded OVA file (double-click or whatever is appropriate for your system). This should start VirtualBox with the "Import" dialog box.

5. Change settings of the virtual machine (you can still change this afterwards by using the Settings menu of VirtualBox). The only things that need your attention:
	- CPU: use the same number of CPUs (i.e. cores) as your laptop (or 1 less)
	- RAM: use about half the RAM of your laptop (assigning too much RAM will slow down your laptop dramatically, using not enough will slow down the virtual machine. 1.5GB seems to be enough though.)
	- Virtual Disk Image: normally this filename is fine but you can save it somewhere else if you like

6. Tick the box "Reinitialise the MAC address of all network cards"

7. Press Import and wait for a few minutes (everything will be decompressed etc).

8. In the VirtualBox window, select your new VM and press the Settings icon. In the "General" category, "Advanced" tab, check that "Shared Clipboard" is set to "bidirectional".

## Running and updating the virtual machine

Now you can start your virtual machine. If it fails to start with an error like "virtualbox vt-x is disabled in the bios", [check here](http://www.howtogeek.com/213795/how-to-enable-intel-vt-x-in-your-computers-bios-or-uefi-firmware/).
If you see a dialog box about "starting in scaled mode", you can press OK to allow VirtualBox to scale the display larger or smaller, or you can press Cancel and start the machine again without scaling. (See [the Virtualbox site](https://www.virtualbox.org/manual/) for some info on the Host-Key etc).

1. You should get a window where Ubuntu 16.04 will be starting (might take a few minutes). Wait until you see the log-in prompt.

2. Log in as user "sirfuser" with password "virtual" (please note that if you have an Azerty-type keyboard, you will have to type "virtuql" until you change your VM keyboard settings). You should get the Gnome3 desktop.

3. Adjust your Ubuntu settings:
	- The keyboard type is set to English-US.
	- Default settings should allow you to access the internet from in the virtual machine. If not, please check [the Virtual Box documentation](http://www.virtualbox.org/manual/ch03.html#settings-network).
	- To change the display resolution (default is 720x400), click on the leftmost button on the bottom bar,
select Preferences->Monitor Settins. Note that your settings will not be saved until you shut down VM,
so you should better shut it down and start again right after setting the display resolution.

4. Click on the activities on the top left corner and write `xterm` in the search box and press enter. This will open a terminal. Type

    update_VM.sh
    
    sudo /home/sirfuser/devel/CCPPETMR_VM/scripts/update_VGA.sh

This commands update the virtual machine and the second fixes a potential mismatch between the installed Virtual Box Guest Addition (VGA) and the version of the virtual box you are running.

To shut down your VM when you are finished with it, use one of the following options. 

1. Close the VM window and use "save machine state" (allowing you to resume from where you were).
2. Shutdown the VM via the Ubuntu interface, or close the VM window and use "Send the shutdown signal". 
(It is not advisable to "power-off" the VM as that can leave the file system of the VM in an undefined state).
3. Use the VirtualBox main window do to any of the above.

