#! /bin/bash

# similar to try/catch
# this line is required for the ubuntu:18.04 base image
apt-get update -y && apt-get install -yq gnupg wget || true
    

# https://developer.nvidia.com/blog/updating-the-cuda-linux-gpg-repository-key/
apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub
