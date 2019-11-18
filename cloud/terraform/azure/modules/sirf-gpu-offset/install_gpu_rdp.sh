#!/bin/bash

sudo killall apt apt-get

if [ -e /var/lib/dpkg/lock-frontend ]; then
    sudo rm /var/lib/dpkg/lock-frontend
fi

if [ -e /var/lib/apt/lists/lock ]; then
    sudo rm /var/lib/apt/lists/lock
fi

if [ -e /var/lib/dpkg/lock ]; then
    sudo rm /var/lib/dpkg/lock
fi

sudo dpkg --configure -a

sudo apt-get install -y ubuntu-desktop
sudo apt-get install -y xrdp
sudo apt-get install -y spyder

head -n -2 /etc/xrdp/startwm.sh > startwm.sh
echo -e "gnome-session\n" >> startwm.sh
sudo mv startwm.sh /etc/xrdp/startwm.sh
chmod 755 /etc/xrdp/startwm.sh

touch 45-allow-colord.pkla
echo "[Allow Colord all Users]" >> 45-allow-colord.pkla
echo "Identity=unix-user:*" >> 45-allow-colord.pkla
echo "Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile" >> 45-allow-colord.pkla
echo "ResultAny=no" >> 45-allow-colord.pkla
echo "ResultInactive=no" >> 45-allow-colord.pkla
echo "ResultActive=yes" >> 45-allow-colord.pkla
sudo mv 45-allow-colord.pkla /etc/polkit-1/localauthority/50-local.d/
chmod 755 /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla

sudo systemctl enable xrdp
sudo systemctl start xrdp