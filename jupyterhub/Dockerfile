ARG BASE_IMAGE=nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04
# paskino/jupyter   datascience-notebook-cuda11
FROM ${BASE_IMAGE} as base

# Make sure the image has the same libraries as the standard SIRF docker image
# Add to the docker image the appropriate stuff
user root
COPY docker/build_essential-ubuntu.sh .
RUN bash build_essential-ubuntu.sh
RUN rm build_essential-ubuntu.sh

# Python (build)
COPY docker/build_python-ubuntu.sh .
RUN bash build_python-ubuntu.sh
RUN rm build_python-ubuntu.sh

# Gadgetron
COPY docker/build_gadgetron-ubuntu.sh .
RUN bash build_gadgetron-ubuntu.sh
RUN rm build_gadgetron-ubuntu.sh

# SIRF external deps
COPY docker/build_system-ubuntu.sh .
RUN bash build_system-ubuntu.sh
RUN rm build_system-ubuntu.sh 


# install requirements from docker/requirements.yml and additional requirements from jupyterhub/requirements.yml
# and requirements for SIRF exercises
ARG PYTHON_INSTALL_DIR="/opt/conda"
ARG PYTHON_EXECUTABLE="miniconda"
COPY docker/user_service-ubuntu.sh .
COPY docker/install-sirf-exercises-dep.py .
RUN PYTHON_EXECUTABLE=${PYTHON_EXECUTABLE} PYTHON_INSTALL_DIR=${PYTHON_INSTALL_DIR} bash user_service-ubuntu.sh
RUN rm user_service-ubuntu.sh install-sirf-exercises-dep.py
# remove the SIRF-Exercises and CIL-Demos that get installed by user_service-ubuntu.sh
RUN rm -rf /opt/SIRF-Exercises; rm -rf /opt/CIL-Demos

USER root
COPY jupyterhub/requirements.yml .
RUN mamba env update -n base -f requirements.yml

# https://docs.docker.com/develop/develop-images/multistage-build/#use-an-external-image-as-a-stage
# not documented in https://docs.docker.com/engine/reference/builder/#copy
# FROM --from=nginx:latest /etc/nginx/nginx.conf /nginx.conf
COPY --from=synerbi/sirf:sirf-core /opt/SIRF-SuperBuild/INSTALL/ /opt/SIRF-SuperBuild/INSTALL
COPY --from=synerbi/sirf:sirf-core /opt/SIRF-SuperBuild/sources/SIRF/ /opt/SIRF-SuperBuild/sources/SIRF/

# Switch back to jovyan to avoid accidental container runs as root
# From https://github.com/paskino/SIRF-SuperBuild/blob/301c2274621e4729cadbd2a1705d8c4d9e3b7e50/docker/Dockerfile#L212-L219
# Set environment variables for SIRF
USER jovyan 
ENV PATH "/opt/conda/bin:/opt/SIRF-SuperBuild/INSTALL/bin:$PATH"
ENV LD_LIBRARY_PATH "/opt/SIRF-SuperBuild/INSTALL/lib:/opt/SIRF-SuperBuild/INSTALL/lib64:$LD_LIBRARY_PATH"
ENV PYTHONPATH "/opt/SIRF-SuperBuild/INSTALL/python"
ENV SIRF_INSTALL_PATH "/opt/SIRF-SuperBuild/INSTALL"
ENV SIRF_EXERCISES_DATA_PATH "/mnt/materials/SIRF/Fully3D/SIRF/"
ENV SIRF_PATH "/opt/SIRF-SuperBuild/sources/SIRF"
#Suppress output from Gadgetron which gives some problems on notebooks (QUIERO)
ENV GADGETRON_LOG_MASK ""
RUN echo $PATH

# switch back to 
USER jovyan

#/opt/SIRF-SuperBuild/INSTALL/lib:/opt/SIRF-SuperBuild/INSTALL/lib64:/usr/local/nvidia/lib:/usr/local/nvidia/lib64::/opt/conda/lib