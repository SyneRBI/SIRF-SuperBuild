#! /bin/bash

{
    apt-get update -y && apt-get install -yq gnupg wget &&\
    # https://developer.nvidia.com/blog/updating-the-cuda-linux-gpg-repository-key/
    apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub

} || {

    # https://developer.nvidia.com/blog/updating-the-cuda-linux-gpg-repository-key/
    apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub

}

