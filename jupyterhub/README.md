## Build the Jupyterhub image 

To create the image with SIRF and all the other stuff required by jupyterhub we start from the `datascience-notebook` from https://github.com/jupyter/docker-stacks.
A few mods for use with Ubuntu 18.04 are in the fork https://github.com/paskino/docker-stacks/tree/base_image_ubuntu18.04 which is used as base for creating the new `datascience-notebook`.

However, we require GPU access (for [CIL](https://github.com/TomographicImaging/CIL.git)) so we need one of the NVIDIA docker images https://hub.docker.com/r/nvidia/cuda/tags?page=1&name=cudnn8-devel-ubuntu18.04 

The strategy is:
  1. to modify the `datascience-notebook` to have the `nvidia/cuda:10.2-cudnn8-devel-ubuntu18.04` base image, `paskino/jupyter:datascience-notebook-cuda10-cudnn8-devel-ubuntu18.04`
  1. build the `synerbi/sirf:sirf-core` image with the `nvidia/cuda:10.2-cudnn8-devel-ubuntu18.04` base image
  1. build the jupyterhub image from the image at point 1, copy the SIRF `INSTALL` directory from the `synerbi/sirf:sirf-core` (previous step), set the appropriate environmental variable and install CIL via conda


### Create the base image for jupyterhub with NVIDIA runtime on Ubuntu 18.04

Currently the `base-notebook` in [`jupyter/docker-stacks`](`https://github.com/jupyter/docker-stacks`) builds on top of Ubuntu 20.04. The `tini` package is [required](https://github.com/jupyter/docker-stacks/blob/f27d615c5052c3a567835ceba3c21ab5d7b0416a/base-notebook/Dockerfile#L39-L42), but it is not available in Ubuntu 18.04 as apt package.  

So to be able to use the `nvidia/cuda:10.2-cudnn8-devel-ubuntu18.04` base image we need to modify the `base-notebook` and install `tini` in another way.
The modifications are available at https://github.com/paskino/docker-stacks/tree/base_image_ubuntu18.04

Below a list of commands that will build the `paskino/jupyter:datascience-notebook-cuda10-cudnn8-devel-ubuntu18.04`

```
git clone git@github.com:paskino/docker-stacks.git
cd docker-stacks
git checkout base_image_ubuntu18.04
cd ..

# base notebook
cd docker-stacks/base-notebook
# change the base class with the ROOT_CONTAINER argument
docker build --build-arg ROOT_CONTAINER=nvidia/cuda:10.2-cudnn8-devel-ubuntu18.04 .
# tag the created image
docker tag 4dbe50ddc554 paskino/jupyter:base-notebook-cuda10-cudnn8-devel-ubuntu18.04

# minimal notebook
cd ../minimal-notebook
docker build --build-arg BASE_CONTAINER=paskino/jupyter:base-notebook-cuda10-cudnn8-devel-ubuntu18.04 .
docker tag 89a140d2318c paskino/jupyter:minimal-notebook-cuda10-cudnn8-devel-ubuntu18.04

# scipy-notebook
cd ../scipy-notebook
docker build --build-arg BASE_CONTAINER=paskino/jupyter:minimal-notebook-cuda10-cudnn8-devel-ubuntu18.04 .
docker tag 36ca7783b57d paskino/jupyter:scipy-notebook-cuda10-cudnn8-devel-ubuntu18.04

# datascience-notebook
cd ../datascience-notebook
docker build --build-arg BASE_CONTAINER=paskino/jupyter:scipy-notebook-cuda10-cudnn8-devel-ubuntu18.04 .
docker tag 5c63287f0aee paskino/jupyter:datascience-notebook-cuda10-cudnn8-devel-ubuntu18.04
```

Finally we have the base `datascience-notebook` with the `nvidia/cuda:11.5.0-cudnn8-devel-ubuntu18.04` base image.

### Start building SIRF

Build the `sirf` target of the SIRF Dockerfile with the `nvidia/cuda:11.5.0-cudnn8-devel-ubuntu18.04` base image.

```
git clone git@github.com:SyneRBI/SIRF-SuperBuild.git
cd SIRF-SuperBuild/docker

# build standard SIRF docker
docker build --build-arg BASE_IMAGE=nvidia/cuda:10.2-cudnn8-devel-ubuntu18.04 --build-arg PYTHON_INSTALL_DIR=/opt/conda --target sirf .

```

#### Building CIL

Please see [here](https://github.com/SyneRBI/SIRF-SuperBuild#building-ccpi-cil) for detailed info on the command below.


```

docker build --build-arg BASE_IMAGE=nvidia/cuda:10.2-cudnn8-devel-ubuntu18.04 --build-arg PYTHON_INSTALL_DIR=/opt/conda --build-arg EXTRA_BUILD_FLAGS="-DBUILD_CIL=ON -DIPP_LIBRARY=/opt/conda/lib -DIPP_INCLUDE=/opt/conda/include -DBUILD_ASTRA=ON" --target sirf . 


# tag as synerbi/sirf:sirf-core
docker tag cd1ed7d07d11 synerbi/sirf:sirf-core
```

### Putting things together



To install SIRF we can literally _copy_ the SIRF INSTALL directory to the `datascience-notebook` image and set the required environment variables.

```
cd SIRF-SuperBuild/docker
docker build --build-arg BASE_IMAGE=paskino/jupyter:datascience-notebook-cuda10-cudnn8-devel-ubuntu18.04 -f ../jupyterhub/Dockerfile .
docker tag 4970647d72ea paskino/sirfcil:service-gpu
```

### Testing

The cloud is set to update the image `paskino/sirfcil:service-gpu`, therefore it is sufficient to tag the image produced in the section above as  
```
docker tag 4970647d72ea paskino/sirfcil:service-gpu
```

### Work in progress
#### base image Ubuntu 20.04 NVIDIA

Work in progress

```
git clone git@github.com:jupyter/docker-stacks.git

# base notebook
cd docker-stacks/base-notebook
# change the base class with the ROOT_CONTAINER argument
docker build --build-arg ROOT_CONTAINER=nvidia/cuda:11.4.2-cudnn8-devel-ubuntu20.04 .
# tag the created image
docker tag 4dbe50ddc554 paskino/jupyter:base-notebook-cuda11
# push to dockerhub
docker push paskino/jupyter:base-notebook-cuda11

# minimal notebook
cd ../minimal-notebook
docker build --build-arg BASE_CONTAINER=paskino/jupyter:base-notebook-cuda11 .
docker tag 4bfaa92b9ed6 paskino/jupyter:minimal-notebook-cuda11

# scipy-notebook
cd ../scipy-notebook
docker build --build-arg BASE_CONTAINER=paskino/jupyter:minimal-notebook-cuda11
docker tag 9cbadae5917e paskino/jupyter:scipy-notebook-cuda11

# datascience-notebook
cd ../datascience-notebook
docker build --build-arg BASE_CONTAINER=paskino/jupyter:scipy-notebook-cuda11 .
```

Build of SIRF on Ubuntu 20.04 [fails](https://github.com/SyneRBI/SIRF-SuperBuild/issues/649)
