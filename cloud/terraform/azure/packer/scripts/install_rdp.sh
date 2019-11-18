#!/bin/bash

sudo apt-get install -y ubuntu-desktop xrdp

mkdir ~/Downloads
cd ~/Downloads

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