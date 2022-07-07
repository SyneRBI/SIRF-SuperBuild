#! /bin/bash

if [ "${PYTHON_EXECUTABLE}" = "ubuntu:18.04" ]; then 
  apt-get install -yq gnupg
fi

# https://developer.nvidia.com/blog/updating-the-cuda-linux-gpg-repository-key/
apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub
