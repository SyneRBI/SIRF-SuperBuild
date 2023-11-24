# Using VirtualBox
VirtualBox allows you to run a Linux Virtual Machine (or other OS) on your PC.
The main VirtualBox documentation is [here](https://www.virtualbox.org/wiki/End-user_documentation). Hopefully it's
rather straightforward however. For instance, once the machine is running, you can use the "View" menu
to set a scale factor if the font is too large or too small, and that you can resize the window. This should resize your Ubuntu desktop accordingly.

The VM is configured as an Ubuntu machine with a single user 'sirfuser' with password 'virtual'.

VirtualBox Guest Additions (VGA) are used to let the VM integrate a bit more with your "host" OS, for instance to allow
copy-pasting between your host and guest. We have these installed in the VM but you will probably have to update them to match your version of VirtualBox. This might be as simple as clicking a link that will briefly appear once you log-in into your VM, but if that doesn't work, we have provided a utility for this. Step-by-step instructions:

1. start the VM and log-in
2. in the menu-bar of the window that contains your VM, click on "Devices" and then "Insert Guest Additions CD" (if this fails, you could try some things [listed here](https://askubuntu.com/questions/573596/unable-to-install-guest-additions-cd-image-on-virtual-box/960324#960324), but ignore the answers about using `apt-get install`)
3. if there appears a window inside your VM to software on this "CD", say OK, otherwise, open a terminal in your VM (see next section on how to open one), type

    sudo ~/devel/SyneRBI_VM/scripts/update_VGA.sh

If during the execution of this scripts a dialog box appears to ask you if you want to auto-run a script, you can press cancel. After this, you probably want to reboot your VM (arrow on top-right of the VM, click on the "power" icon).

# Gnome 3
Our current VM is based on Ubuntu 22.04 using the [Gnome3](https://www.gnome.org/gnome-3/) window manager. This might
be somewhat unfamiliar to you. The main thing to note is the "Activities" at the top-left of the screen. Click that to be able to switch between applications or launch a new one, for instance by clicking on the "grid" icon on the lower-left, or typing its name in the search box (e.g. "terminal").

Note that if you want to open two terminals, you will have to right-click on the terminal icon and select "New window".

We ship the VM with a minimal set of applications. If you want, you can expand this considerably by typing

     sudo apt-get install ubuntu-gnome-desktop

Note that you can change keyboard-type by clicking on the relevant icon in the top-right of the VM.

# Updating your VM
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

