#!/bin/bash

sudo apt-get install -y ubuntu-desktop spyder

mkdir ~/Downloads
cd ~/Downloads
wget https://ccppetmrfiles.blob.core.windows.net/misc/install-xrdp-1.9.1.sh
chmod +x install-xrdp-1.9.1.sh
sudo bash install-xrdp-1.9.1.sh
