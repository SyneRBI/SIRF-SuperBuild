ARG BASE_IMAGE=ubuntu:18.04
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


# install requirements skipping CIL ones that are taken care of by conda
# COPY requirements_conda_forge.txt .
# RUN conda install -c conda-forge -c intel -c astra-toolbox -c ccpi --file requirements_conda_forge.txt

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