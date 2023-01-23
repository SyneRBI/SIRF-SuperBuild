## Build the Jupyterhub image 

To create the image with SIRF and all the other stuff required by jupyterhub we start from the `datascience-notebook` from https://github.com/jupyter/docker-stacks.
A few mods for use with Ubuntu 18.04 are in the fork https://github.com/paskino/docker-stacks/tree/base_image_ubuntu18.04 which is used as base for creating the new `datascience-notebook`.

However, we require GPU access (for [CIL](https://github.com/TomographicImaging/CIL.git)) so we need one of the NVIDIA docker images https://hub.docker.com/r/nvidia/cuda/tags?page=1&name=cudnn8-devel-ubuntu18.04 

The strategy is:
  1. to modify the `datascience-notebook` to have the `nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04` base image, `paskino/jupyter:datascience-notebook-cuda10-cudnn8-devel-ubuntu18.04`
  1. build the `synerbi/sirf:sirf-core` image with the `nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04` base image
  1. build the jupyterhub image from the image at point 1, copy the SIRF `INSTALL` directory from the `synerbi/sirf:sirf-core` (previous step), set the appropriate environmental variable and install CIL via conda


### Create the base image for jupyterhub with NVIDIA runtime on Ubuntu 22.04

Currently the `base-notebook` in [`jupyter/docker-stacks`](`https://github.com/jupyter/docker-stacks`) builds on top of Ubuntu 22.04. 

To be able to use the `nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04` base image we need to modify the `base-notebook` up to `datascience-notebook`.

Below a list of commands that will build the `datascience-notebook` with the NVIDIA cuda base image, which I then tag as `paskino/jupyter:datascience-notebook-cuda11-cudnn8-devel-ubuntu22.04`

#### Clone the docker-stacks repo

```
git clone git@github.com:jupyter/docker-stacks.git
```

#### Build the images

```
# base notebook
cd docker-stacks/base-notebook
# change the base class with the ROOT_CONTAINER argument
# build and tag
docker build --build-arg ROOT_CONTAINER=nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04 -t paskino/jupyter:base-notebook-cuda11-cudnn8-devel-ubuntu22.04 .

# minimal notebook
cd ../minimal-notebook
docker build --build-arg BASE_CONTAINER=paskino/jupyter:base-notebook-cuda11-cudnn8-devel-ubuntu22.04 -t paskino/jupyter:minimal-notebook-cuda11-cudnn8-devel-ubuntu22.04 .


# scipy-notebook
cd ../scipy-notebook
docker build --build-arg BASE_CONTAINER=paskino/jupyter:minimal-notebook-cuda11-cudnn8-devel-ubuntu22.04 -t paskino/jupyter:scipy-notebook-cuda11-cudnn8-devel-ubuntu22.04 .

# datascience-notebook
cd ../datascience-notebook
docker build --build-arg BASE_CONTAINER=paskino/jupyter:scipy-notebook-cuda11-cudnn8-devel-ubuntu22.04 -t paskino/jupyter:datascience-notebook-cuda11-cudnn8-devel-ubuntu22.04 .
```

Finally we have the base `datascience-notebook` with the `nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04` base image.


Possible fix for plotting.
```
conda update -c conda-forge jupyterlab ipympl
%matplotlib widget
```

### Start building SIRF

Build the `sirf` target of the SIRF Dockerfile with the `nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04` base image.

```
git clone git@github.com:SyneRBI/SIRF-SuperBuild.git
cd SIRF-SuperBuild/docker

# build standard SIRF docker
docker build --build-arg BASE_IMAGE=nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04 --build-arg PYTHON_INSTALL_DIR=/opt/conda --target sirf .

```

#### Building CIL

Please see [here](https://github.com/SyneRBI/SIRF-SuperBuild#building-ccpi-cil) for detailed info on the command below.


```

 docker build --build-arg BASE_IMAGE=nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04 --build-arg PYTHON_INSTALL_DIR=/opt/conda --build-arg EXTRA_BUILD_FLAGS="-DBUILD_CIL=ON -DIPP_LIBRARY=/opt/conda/lib -DIPP_INCLUDE=/opt/conda/include" --build-arg SIRF_SB_URL="https://github.com/paskino/SIRF-SuperBuild.git" --build-arg SIRF_SB_TAG="jupyterhub_env" --build-arg NUM_PARALLEL_BUILDS=6 --target sirf -t synerbi/sirf:sirf-core .
```
# build for PSMRTBP2022
```
 nohup docker build --build-arg BASE_IMAGE=nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04 --build-arg PYTHON_INSTALL_DIR=/opt/conda --build-arg EXTRA_BUILD_FLAGS="-DBUILD_CIL=ON -DIPP_LIBRARY=/opt/conda/lib -DIPP_INCLUDE=/opt/conda/include -DSTIR_URL=https://github.com/UCL/STIR.git -DSTIR_TAG=master -DBUILD_STIR_EXECUTABLES=ON -DSIRF_URL=https://github.com/SyneRBI/SIRF.git -DSIRF_TAG=lm-recon -Dparallelproj_TAG=v0.8" --build-arg SIRF_SB_URL="https://github.com/paskino/SIRF-SuperBuild.git" --build-arg SIRF_SB_TAG="jupyterhub_env" --build-arg NUM_PARALLEL_BUILDS=6 --target sirf -t synerbi/sirf:psmrtbp2022 . > build_jupyterhub_lm.log &
```

### Putting things together



To install SIRF we can literally _copy_ the SIRF INSTALL directory to the `datascience-notebook` image and set the required environment variables.

```
cd SIRF-SuperBuild
docker build --build-arg BASE_IMAGE=paskino/jupyter:datascience-notebook-cuda11-cudnn8-devel-ubuntu22.04 -f jupyterhub/Dockerfile -t paskino/sirfcil:service-gpu .
```

### Testing

The cloud is set to update the image `paskino/sirfcil:service-gpu`, therefore it is sufficient to tag the image produced in the section above as  
```
docker tag 4970647d72ea paskino/sirfcil:service-gpu
```

