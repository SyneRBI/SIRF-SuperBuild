#! /bin/bash
if [ -n "${BASE_IMAGE}" ]; then 
  bm=$BASE_IMAGE
else
  bm="ubuntu:18.04"
fi

if [ ${bm} = "ubuntu:18.04" ]; then 
  apt-get update -y
  apt-get install -yq gnupg wget
fi

# https://developer.nvidia.com/blog/updating-the-cuda-linux-gpg-repository-key/
apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub
