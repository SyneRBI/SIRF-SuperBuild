#! /bin/bash

# similar to try/catch
# these lines are required for the ubuntu:18.04 base image, 
# but we allow them to fail as they can on a GPU image before the keys as added.
apt-get update -y  || true
apt-get install -yq gnupg wget || true
    

# https://developer.nvidia.com/blog/updating-the-cuda-linux-gpg-repository-key/
apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/3bf863cc.pub
