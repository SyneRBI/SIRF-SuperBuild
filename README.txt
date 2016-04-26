# CCPPETMR_VM

=====================================================
Virtual Machine installation and running instructions
=====================================================

If you have any problems, please first re-check this web-page. 
If you cannot solve your issue, please email 
k dot thielemans at ucl dot ac dot uk.

---------------------------------
Initial download and installation
---------------------------------

1. Make sure you have enough free disk-space on your laptop 
(~10GB for installation).

2. Install VirtualBox (https://www.virtualbox.org). Please note 
that this will require administrator permissions. 
You do not need to install the Oracle extensions to VirtualBox, 
although it might come in handy for USB support. 
Although other Virtual Machine software might work, we have not 
tried this and will not be able to help to get this going. 
Nikos Efthimiou says that if you run Ubuntu (or similar) on your laptop, 
VirtualBox might not install, unless you first upgrade to libvpx>1. 
You could try the following (but you might want to read-up on this first):
  - wget http://launchpadlibrarian.net/199480915/libvpx1_1.3.0-3ubuntu1_amd64.deb
  - sudo dpkg -i libvpx1*.deb

3. Download Lubuntu_CCPPETMR_VM.ova from UCL Dropbox (instructions 
for downloading will be sent by e-mail). Warning: this file is ~1.8GB. 
(You can of course download to a USB stick to save space on your laptop).

4. Open the downloaded OVA file (double-click or whatever is appropriate 
for your system). This should start VirtualBox with the "Import" dialog box.

5. Change settings of the virtual machine (you can still change this 
afterwards by using the Settings menu of VirtualBox). The only things that 
need your attention:
  - CPU: use the same number of CPUs (i.e. cores) as your laptop (or 1 less)
  - RAM: use about half the RAM of your laptop (assigning too much RAM will 
	slow down your laptop dramatically, using not enough will slow down 
	the virtual machine. 1.5GB seems to be enough though.)
  - Virtual Disk Image: normally this filename is fine but you can save it 
	somewhere else if you like

6. Tick the box "Reinitialise the MAC address of all network cards"

7. Press Import and wait for a few minutes (everything will be decompressed etc).

8. In the VirtualBox window, select your new VM and press the Settings icon. 
In the "General" category, "Advanced" tab, check that "Shared Clipboard" is 
set to "bidirectional".

----------------------------------------
Running and updating the virtual machine
----------------------------------------

Now you can start your virtual machine. If it fails to start with an error 
like "virtualbox vt-x is disabled in the bios", check 
http://www.howtogeek.com/213795/how-to-enable-intel-vt-x-in-your-computers-bios-or-uefi-firmware/.
If you see a dialog box about "starting in scaled mode", you can press OK 
to allow VirtualBox to scale the display larger or smaller, or you can press 
Cancel and start the machine again without scaling. (See the Virtualbox site 
https://www.virtualbox.org/manual/ for some info on the Host-Key etc).

1. You should get a window where Lubuntu will be starting (might take a few 
minutes). Wait until you see the log-in prompt.

2. Log in as user "stir" with password "virtual" (please note that if you have 
an Azerty-type keyboard, you will have to type "virtuql" until you change your 
Lubuntu keyboard settings). You should get the Lubuntu desktop.

3. Adjust your Ubuntu settings:
  - The keyboard type is set to English-UK. If this is not ok
	- Right-click on the bottom bar of the desktop;
	- Select "Add/Remove Panel Items";
	- Click the "Add" button on the right hand side;
	- Scroll down the list and select "Keyboard Layout Handler" and then 
		click "Add" then close;
	- You will see an English flag on the bottom right corner of the screen, 
		that relates to the keyboard, right-click on it and choose 
		"Keyboard Layout Handler Settings";
	- Remove the tick from "Keep System layouts" then the click on the "Add" 
		button and choose the flag depending on your keyboard and then "OK";
	- Click "Close";
	- Now on the bottom right corner you should see the flag you selected or 
		the English flag, if you left-click on the flag, it will change 
		from one keyboard to the other, pick the chosen one.
  - Default settings should allow you to access the internet from in the virtual 
	machine. If not, please check the Virtual Box documentation 	(http://www.virtualbox.org/manual/ch03.html#settings-network).
  - To change the display resolution (default is 720x400), click on the leftmost 
	button on the bottom bar, select Preferences->Monitor Settins. Note that 
	your settings will not be saved until you shut down VM, so you should 
	better shut it down and start again right after setting the display 
	resolution.

4. Double-click on the LXTerminal icon to open a terminal. Type

      update_VM.sh

To shut down your VM when you are finished with it, use one of the following 
options: 
  - Close the VM window and use "save machine state" (allowing you to resume 
	from where you were).
  - Shutdown the VM via the Lubuntu interface, or close the VM window and use 
	"Send the shutdown signal". (It is not advisable to "power-off" the VM 
	as that can leave the file system of the VM in an undefined state).
  - Use the VirtualBox main window do to any of the above.

-----------------------------------------------------
Shared folders and other VirtualBox advanced features
-----------------------------------------------------

This section is optional.

Things work smoother if you have the VirtualBox Guest Additions (VGA, 
https://www.virtualbox.org/manual/ch04.html), essentially a set of drivers for 
the guest OS. The VM has these already installed but they will work properly 
if you have VirtualBox 4.3.30. Fortunately, it is not very hard to install the 
VGA for your VirtualBox version. Please follow the standard instructions (https://www.virtualbox.org/manual/ch04.html#idp45859068609968), skipping step 1 
(about dkms) as this has been done for you. Reboot your VM after installing the 
VGA. Please do this AFTER updating your VM as above.

After installing the VGA, you might want to configure a shared directory between 
the host and the guest machine such that your virtual machine can "see" your 
"normal" files. Please read the Virtualbox documentation on Folder Sharing 
(http://www.virtualbox.org/manual/ch04.html#sharedfolders). Summary of steps 
(courtesy Nikos Efthimiou):

1. Right click on the Lubuntu VM in VirtualBox main window and choose Settings.
2. Choose "Shared Folders" (last item on the left).
3. Add new folder, select the folder you want, and give it a name, e.g. MyLaptop 
(use small + button near the right edge of the dialog).
4. Select folder and opt in "make permanent" and "auto mount".
5. Start the Lubuntu VM (or switch to it) and open a terminal and type

        mkdir ~/MyLaptop
        sudo mount -t vboxsf -o rw,uid=1000,gid=1000 MyLaptop ~/MyLaptop
      
You will have to type the last command whenever you reboot your VM, or you could 
make this permanent by pasting the above command to /etc/rc.local before "exit 0" 
(non-trivial because of admin permissions).
