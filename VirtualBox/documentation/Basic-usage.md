# Using the SyneRBI Virtual Machine with VirtualBox

Here we describe how to configure and use the VM. Check the [README.md](README.md) for installation and other pointers.

## Minimal information on VirtualBox

The main VirtualBox documentation is [here](https://www.virtualbox.org/wiki/End-user_documentation). Hopefully it's
rather straightforward however. For instance, once the machine is running, you can use the "View" menu
to set a scale factor if the font is too large or too small, and that you can resize the window. This should resize your Ubuntu desktop accordingly.

[VirtualBox Guest Additions](https://www.virtualbox.org/manual/ch04.html) (VGA) are used to let the VM integrate with your "host" OS, for instance to allow
copy-pasting between your host and guest. We have these installed in the VM but if you use our pre-built VM, you will have to update them to match your version of VirtualBox, see below.

## Initial configuration of the virtual machine

Start your virtual machine. If it fails to start with an error like "*virtualbox vt-x is disabled in the bios*", [check here](http://www.howtogeek.com/213795/how-to-enable-intel-vt-x-in-your-computers-bios-or-uefi-firmware/).
If you see a dialog box about "starting in scaled mode", you can press OK to allow VirtualBox to scale the display larger or smaller, or you can press Cancel and start the machine again without scaling. (See [the Virtualbox site](https://www.virtualbox.org/manual/) for some info on the Host-Key etc).

1. You should get a window where Ubuntu 22.04 will be starting (might take a few minutes). Wait until you see the log-in prompt.

2. Log in as user "sirfuser" with password "virtual" (please note that the default keyboard is with `en_GB` locale: if you have an Azerty-type keyboard, you will have to type "virtuql" until you change your VM keyboard settings). You should get the [Gnome3](https://www.gnome.org/gnome-3/) desktop. The main thing to note is the "Activities" at the top-left of the screen. Click that to be able to launch a terminal, for instance by clicking on the "grid" icon on the lower-left, or typing "terminal" in the search box.

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

4. Make sure your Virtual Guest Additions (VGA) version matches your VirtualBox version.<br />
In the menu-bar of the window that contains your VM, click on "Devices" and then "Insert Guest Additions CD". (On a Mac, with the VM window selected, this menu bar is at the top of the screen).
If this generates a window inside your VM to run the software on this "CD", say OK. Otherwise, type

   ```sh
   sudo /home/sirfuser/devel/SIRF-SuperBuild/VirtualBox/scripts/update_VGA.sh
   sudo shutdown -r now
   ```
   The VM will reboot. (You will have to do this again if you upgrade your VirtualBox version).

5. We ship the VM with a minimal set of applications. If you want, you can expand this considerably by typing
   ```sh
   sudo apt-get install ubuntu-gnome-desktop
   ```

## How to shut down the VM

To shut down your VM when you are finished with it, use one of the following options. 

1. Close the VM window and use "save machine state" (allowing you to resume from where you were).
2. Shutdown the VM via the Ubuntu interface (arrow in top-right corner), or close the VM window
and use "Send the shutdown signal". 
(It is not advisable to "power-off" the VM as that can leave the file system of the VM in an undefined state).
3. Use the VirtualBox main window to do any of the above.

## Optional: use shared folders

You might want to configure a shared directory between the host and the guest machine such that your virtual machine can "see" your "normal" files. Please read [the Virtualbox documentation on Folder Sharing](http://www.virtualbox.org/manual/ch04.html#sharedfolders). 
Summary of steps (courtesy Nikos Efthimiou):
 
 1. Right click on the SyneRBI VM in the .VirtualBox main window and choose Settings.
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


## Updating your VM

We  provide a script to update an existing VM to a new version of course software. Note however that in some cases (e.g. when updating to SIRF 3.5.0) this won't work as the underlying Ubuntu OS needs updating as well. It is then probably easiest to download the new VM instead. (You could try to update Ubuntu first if you really wish to).

If you have decided to upgrade your existing VM, type the following in a terminal

     update_VM.sh -s

The `-s` option will update your system dependencies via APT.

The script has some additional options for advanced usage only. For instance, if you
are a developer and want to use the latest version of the software and want
to run 10 build processes simultaneously, you could do

     update_VM.sh -t master -j 10

Note that this will currently update the SIRF-SuperBuild software, but still use the `DEVEL_BUILD=OFF` option, see [here](https://github.com/SyneRBI/SIRF-SuperBuild#Building-with-specific-versions-of-dependencies) for more information.

Of course, we recommend making a copy of your VM, or a [snapshot](https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/snapshots.html) before doing an update.

