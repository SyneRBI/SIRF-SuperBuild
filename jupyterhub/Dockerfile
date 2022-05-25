ARG BASE_IMAGE=ubuntu:18.04
# paskino/jupyter   datascience-notebook-cuda11
FROM ${BASE_IMAGE} as base

# Make sure the image has the same libraries as the standard SIRF docker image
# Add to the docker image the appropriate stuff
user root
COPY build_essential-ubuntu.sh .
RUN bash build_essential-ubuntu.sh
RUN rm build_essential-ubuntu.sh

# Python (build)
COPY build_python-ubuntu.sh .
RUN bash build_python-ubuntu.sh
RUN rm build_python-ubuntu.sh

# Gadgetron
COPY build_gadgetron-ubuntu.sh .
RUN bash build_gadgetron-ubuntu.sh
RUN rm build_gadgetron-ubuntu.sh

# SIRF external deps
COPY build_system-ubuntu.sh .
RUN bash build_system-ubuntu.sh
RUN rm build_system-ubuntu.sh 

# copy tini in /usr/bin because I installed tini in / rather than in the path
# in the base-notebook, see
# https://github.com/paskino/docker-stacks/blob/8d4c9922710debc22e229dbcdc91f8fcd613db52/base-notebook/Dockerfile#L22-L27
RUN cp /tini /usr/bin
RUN chmod +x /usr/bin/tini

# install requirements skipping CIL ones that are taken care of by conda
COPY requirements_conda_forge.txt .
RUN conda install -c conda-forge -c intel -c astra-toolbox -c ccpi --file requirements_conda_forge.txt
RUN python -m pip install git+https://github.com/ismrmrd/ismrmrd-python-tools.git@master#egg=ismrmrd-python-tools

RUN python -m pip install torch==1.7.1 scikit-image

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
RUN echo $PATH

# switch back to 
USER jovyan

#/opt/SIRF-SuperBuild/INSTALL/lib:/opt/SIRF-SuperBuild/INSTALL/lib64:/usr/local/nvidia/lib:/usr/local/nvidia/lib64::/opt/conda/lib