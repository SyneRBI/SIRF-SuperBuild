## Build the Jupyterhub image 

Jupyterhub uses images from `https://github.com/jupyter/docker-stacks`_ which I cloned in `https://github.com/paskino/docker-stacks`_

### create the base image for jupyterhub


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

# Start building SIRF

cd SIRF-SuperBuild/docker
# I tagged the output of the previous step as 
# paskino/jupyter   datascience-notebook-cuda11
# AND (because this is how it is picked by the jupyterhub instance, 
# so by updating the image paskino/sirfcil:service-gpu I can test that everything works)
# paskino/sirfcil:service-gpu

# build the core target
docker build --build-arg BASE_IMAGE=paskino/sirfcil:service-gpu --target core .
```