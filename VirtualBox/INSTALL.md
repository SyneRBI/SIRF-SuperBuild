# SyneRBI Virtual Machine: Installation and running of pre-built machine

If you have any problems, please first re-check this web-page. If you cannot solve your issue, please email syneRBI-USERS @ JISCMAIL.AC.UK


## Initial download and installation
This section assumes you want to use our pre-configured VM (which is recommended!). If you want to build a new VM yourself, then check the [README](README.md) for instructions.

1. Make sure you have enough free disk-space on your laptop (~10GB for installation).

2. Install VirtualBox (VB), our [Download page](http://www.ccpsynerbi.ac.uk/downloads) specifies the recommended version. 
(If it is older than the current default download from VB, you can [get an older version here](https://www.virtualbox.org/wiki/Download_Old_Builds)). Please note that this will require administrator permissions on your computer. The "host" operating system refers to your computer. 
You do not need to install the Oracle extensions to VirtualBox, although it might come in handy for USB support. 
Although other Virtual Machine software might work, we have not tried this and will not be able to help to get this going.
  Some extra pointers if you experience problems with installing VirtualBox
    - On older Ubuntu versions (e.g. 15.10), there were some problems installing VirtualBox related to `libvpx`, [check here for some help](https://forums.virtualbox.org/viewtopic.php?f=7&t=74050).
    - If your VirtualBox is too old, you might experience problems with networking etc. Please use at least 5.0.40 (at least 5.2.6 on a Mac).
    
    For Macs, the installation of Virtual Box might require you to alter your security settings. 
    - If you receive an error along the lines of `kernel driver not installed (rc=-1908)`, the following might help. Click on the Apple icon in the top-left of your screen and then `System Preferences->Security & Privacy->General`. Click the padlock in the bottom-left and enter your password to be able to make changes to this page. Click `Allow` next to the Virtual Box text. Hopefully the problem will have been sorted.
    - If the installation takes you directly to the `Security and Privacy` window, select `Allow` (the VB is labelled as from Oracle). When the installer asks if it should Move to Trash, say `Keep` because you need to re-run the installation again with this revised security setting. Second time around, you can move it to trash.

3. Download the preinstalled virtual machine from http://www.ccpsynerbi.ac.uk/downloads.
Warning: this file can be ~4.9GB. (You can download to a USB stick or hard drive to save space on your hard-disk).

4. Open the downloaded OVA file (double-click or whatever is appropriate for your system). This should start VirtualBox with the "Import" dialog box.

5. Change settings of the virtual machine (you can still change this afterwards by using the Settings menu of VirtualBox). The only things that need your attention:
	- CPU: use the same number of CPUs (i.e. cores) as your laptop (or 1 less)
	- RAM: use about half the RAM of your laptop (assigning too much RAM will slow down your laptop dramatically, using not enough will slow down the virtual machine. 1.5GB seems to be enough for most things though.)
	- Virtual Disk Image: normally this filename is fine but you can save it somewhere else if you like

6. If still present, tick the box "Reinitialise the MAC address of all network cards"

7. Press Import and wait for a few minutes (everything will be decompressed etc).

8. In the VirtualBox window, select your new VM and press the Settings icon. In the "General" category, "Advanced" tab, check that "Shared Clipboard" is set to "bidirectional".

## Initial configuration of the virtual machine

Now you can start your virtual machine. If it fails to start with an error like "*virtualbox vt-x is disabled in the bios*", [check here](http://www.howtogeek.com/213795/how-to-enable-intel-vt-x-in-your-computers-bios-or-uefi-firmware/).
If you see a dialog box about "starting in scaled mode", you can press OK to allow VirtualBox to scale the display larger or smaller, or you can press Cancel and start the machine again without scaling. (See [the Virtualbox site](https://www.virtualbox.org/manual/) for some info on the Host-Key etc).

1. You should get a window where Ubuntu 18.04 will be starting (might take a few minutes). Wait until you see the log-in prompt.

2. Log in as user "sirfuser" with password "virtual" (please note that the default keyboard is with `en_GB` locale: if you have an Azerty-type keyboard, you will have to type "virtuql" until you change your VM keyboard settings). You should get the Gnome3 desktop.

3. Adjust your Ubuntu settings:
    - Default settings should allow you to access the internet from in the virtual machine.
      If not, please check [the Virtual Box documentation](http://www.virtualbox.org/manual/ch03.html#settings-network).
    - The keyboard type is set to English-UK. There are currently a few preinstalled layouts, including en_GB, en_US, Portuguese, Spanish etc.
      You can change keyboard-type by clicking on the relevant icon in the top-right of the VM.
      If you cannot find the layout that you need (e.g. to switch to a Mac keyboard), open a terminal by clicking "Activities" at top left and type "terminal" in the search box, then use

      ```
      sudo dpkg-reconfigure keyboard-configuration
      ```

    - To adjust other system settings you can click on the right top corner and then click on the tools icon (spanner and screwdriver) to start the settings app, or click on "Activities" on the top left corner and then type "settings" in the search box and it should open the settings apps. If the text and windows are so large it makes using the settings app difficult, try changing the scaling by pressing the small display icon near the bottom right of the VB window. 

4. The VM has been created with a particular version of Virtual Box (see the Download page) and with the [VirtualBox Guest Additions](https://www.virtualbox.org/manual/ch04.html) (VGA) pre-installed. If you have a different (or even the same) version of Virtual Box you might experience [issues](https://github.com/SyneRBI/SyneRBI_VM/issues/9), especially [running the X server](https://github.com/SyneRBI/SyneRBI_VM/issues/60#issuecomment-367611385). If you are using a different version of VirtualBox we therefore strongly recommend to sync your VGA version as follows:\
In the menu-bar of the window that contains your VM, click on "Devices" and then "Insert Guest Additions CD". (On a Mac, with the VM window selected, this menu bar is at the top of the screen). If this generates a window inside your VM to run the software on this "CD", say OK. Otherwise, type

  ```
   sudo /home/sirfuser/devel/SIRF-SuperBuild/VirtualBox/scripts/update_VGA.sh
   sudo shutdown -r now
  ```
The VM will reboot. (You will have to do this again if you upgrade your VirtualBox version).

5. On old VM versions (e.g. 20 April 2018, SIRF_1.0.0) people were reporting problems after the VM is shutdown or rebooted, but this problem no longer seems to exist. The VM windows system may fail to start and you are left with a flashing VM terminal window that stabilises after a few minutes. If your cursor has gone, it may be "in" this terminal window and can be released (press the Host Key (on most systems, right-ctrl, on a Mac the Apple command key). To restore proper functionality, follow the instructions in point 5 above, even if you already had the correct VGA installed. If you have previously 'inserted' the CD you may get an error message that you need to ignore. Then reboot.

## Usage 
Check our [documentation](documentation/README.md) for usage instructions.

## How to shut down the VM

To shut down your VM when you are finished with it, use one of the following options. 

1. Close the VM window and use "save machine state" (allowing you to resume from where you were).
2. Shutdown the VM via the Ubuntu interface (arrow in top-right corner), or close the VM window
and use "Send the shutdown signal". 
(It is not advisable to "power-off" the VM as that can leave the file system of the VM in an undefined state).
3. Use the VirtualBox main window to do any of the above.

## Shared folders
 
This section is optional.
 
Warning: in VB versions before 6.0.6, we strongly recommend to copy data from a shared folder to a “local” folder (in your VM) to avoid a problem with [a VB bug](https://www.virtualbox.org/ticket/9485).
 
After installing the VGA, you might want to configure a shared directory between the host and the guest machine such that your virtual machine can "see" your "normal" files. Please read [the Virtualbox documentation on Folder Sharing](http://www.virtualbox.org/manual/ch04.html#sharedfolders). 
Summary of steps (courtesy Nikos Efthimiou):
 
 1. Right click on the SyneRBI VM in VirtualBox main window and choose Settings.
 2. Choose "Shared Folders".
 3. Add new folder (use small + button near the right edge of the dialog), select the folder you want, and give it a name, e.g. MyLaptop.
 4. Select folder and check "make permanent" and "auto mount".
 5. Start the SyneRBI VM (or switch to it) and open a terminal and type
 
         mkdir ~/MyLaptop
         sudo mount -t vboxsf -o rw,uid=1002,gid=1002 MyLaptop ~/MyLaptop
 The '1002's in the above refer to the user and group ids of the user. These are not always 1002 - to check, at the command line, type the command `id`.
 
 You will have to type the last command whenever you reboot your VM, or you could make this permanent by pasting the above command to /etc/rc.local before "exit 0" (non-trivial because of admin permissions). 

If you want you can unmount the folder by typing

        sudo umount -t vboxsf MyLaptop

## Using the VM as a Gadgetron server

See [here](documentation/Using-VM-as-a-Gadgetron-server.md)
