## Build the Jupyterhub image 

Jupyterhub uses images from `https://github.com/jupyter/docker-stacks`_ which I cloned in `https://github.com/paskino/docker-stacks`_

### create the base image for jupyterhub

# base image Ubuntu 18.04 NVIDIA

Need to modify `base-notebook` as `tini` is required and not in the `nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04` base image.

```
git clone git@github.com:jupyter/docker-stacks.git
git clone git@github.com:stfc/cloud-docker-images.git

# base notebook
cd docker-stacks/base-notebook
# change the base class with the ROOT_CONTAINER argument
docker build --build-arg ROOT_CONTAINER=nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04 .
# tag the created image
docker tag 4dbe50ddc554 paskino/jupyter:base-notebook-cuda10-ubuntu18.04

# minimal notebook
cd ../minimal-notebook
docker build --build-arg BASE_CONTAINER=paskino/jupyter:base-notebook-cuda10-ubuntu18.04 .
docker tag 4bfaa92b9ed6 paskino/jupyter:minimal-notebook-cuda10-ubuntu18.04

# scipy-notebook
cd ../scipy-notebook
docker build --build-arg BASE_CONTAINER=paskino/jupyter:minimal-notebook-cuda10-ubuntu18.04 .
docker tag 9cbadae5917e paskino/jupyter:scipy-notebook-cuda10-ubuntu18.04

# datascience-notebook
cd ../datascience-notebook
docker build --build-arg BASE_CONTAINER=paskino/jupyter:scipy-notebook-cuda10-ubuntu18.04 .
docker tag aec093c609c5 paskino/jupyter:datascience-notebook-cuda10-ubuntu18.04
```

# Start building SIRF



```
git clone git@github.com:SyneRBI/SIRF-SuperBuild.git
cd SIRF-SuperBuild/docker
# I tagged the output of the previous step as 
# paskino/jupyter   datascience-notebook-cuda11
# AND (because this is how it is picked by the jupyterhub instance, 
# so by updating the image paskino/sirfcil:service-gpu I can test that everything works)
# paskino/sirfcil:service-gpu

# build standard SIRF docker
docker build --build-arg NUM_PARALLEL_BUILDS=1 --build-arg BASE_IMAGE=nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04 --target sirf .
# cd1ed7d07d11


```

```
# this will build on top of a GPU enabled docker datascience-notebook
# and copy stuff from the sirf image, i.e. the INSTALL directory
# and install CIL via conda
# To be able to access the files in the docker directory one needs to launch 
# docker build from that directory and point to the Dockerfile in the other

docker build --build-arg BASE_IMAGE=paskino/jupyter:datascience-notebook-cuda10-ubuntu18.04 -f ../jupyterhub/Dockerfile .
```

entrypoint for tini is defined in the base-notebook Dockerfile


# base image Ubuntu 20.04 NVIDIA

```
git clone git@github.com:jupyter/docker-stacks.git
git clone git@github.com:stfc/cloud-docker-images.git

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