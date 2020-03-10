#!/bin/bash

sudo parted /dev/sdc mklabel gpt
sudo parted -a opt /dev/sdc mkpart primary ext4 0% 100%
sudo mkfs.ext4 /dev/sdc1
sudo mkdir /data
sudo sh -c  "echo '/dev/sdc1       /data        ext4   defaults,discard        0 0' >> /etc/fstab"
