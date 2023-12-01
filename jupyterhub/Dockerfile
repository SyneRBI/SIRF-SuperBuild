# syntax=docker/dockerfile:1
ARG BASE_CONTAINER=nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04
FROM ${BASE_CONTAINER} as base

# Make sure the image has the same libraries as the standard SIRF docker image
# Add to the docker image the appropriate stuff
USER root
COPY --chown=jovyan:users docker/build_essential-ubuntu.sh docker/build_gadgetron-ubuntu.sh docker/build_system-ubuntu.sh docker/install-sirf-exercises-dep.py ./scripts/
RUN bash ./scripts/build_essential-ubuntu.sh &&\
    bash ./scripts/build_gadgetron-ubuntu.sh &&\
    bash ./scripts/build_system-ubuntu.sh


ARG SIRF_IMAGE="synerbi/sirf:latest"
# https://docs.docker.com/develop/develop-images/multistage-build/#use-an-external-image-as-a-stage
# not documented in https://docs.docker.com/engine/reference/builder/#copy
# FROM --from=nginx:latest /etc/nginx/nginx.conf /nginx.conf
COPY --from=${SIRF_IMAGE} --link /opt/SIRF-SuperBuild/INSTALL/ /opt/SIRF-SuperBuild/INSTALL
COPY --from=${SIRF_IMAGE} --link /opt/SIRF-SuperBuild/sources/SIRF/ /opt/SIRF-SuperBuild/sources/SIRF/

FROM base AS jup
# remove the SIRF-Exercises and CIL-Demos that get installed by user_service-ubuntu.sh
USER jovyan
ARG NB_USER="jovyan"
ARG NB_GROUP="users"


COPY --chown=jovyan:users docker/requirements.yml docker/
COPY --chown=jovyan:users jupyterhub/requirements.yml docker/requirements-service.yml jupyterhub/


# RUN mamba env update -n base -f docker/requirements.yml
# RUN mamba env update -n base -f jupyterhub/requirements.yml

# RUN bash ./scripts/user_service-ubuntu.sh &&\
RUN mamba env update -n base -f docker/requirements.yml &&\
    mamba env update -n base -f jupyterhub/requirements.yml &&\
    git clone https://github.com/SyneRBI/SIRF-Exercises --recursive -b master SIRF-Exercises &&\
    python scripts/install-sirf-exercises-dep.py SIRF-Exercises/requirements.txt &&\
    mamba env update -n base -f jupyterhub/requirements.yml &&\
    rm -rf docker && rm -rf jupyterhub &&\
    rm -rf ./scripts

# Switch back to jovyan to avoid accidental container runs as root
# From https://github.com/paskino/SIRF-SuperBuild/blob/301c2274621e4729cadbd2a1705d8c4d9e3b7e50/docker/Dockerfile#L212-L219
# Set environment variables for SIRF
USER jovyan
COPY docker/.bashrc /home/jovyan
ENV PATH "/opt/conda/bin:/opt/SIRF-SuperBuild/INSTALL/bin:$PATH"
ENV LD_LIBRARY_PATH "/opt/SIRF-SuperBuild/INSTALL/lib:/opt/SIRF-SuperBuild/INSTALL/lib64:$LD_LIBRARY_PATH"
ENV PYTHONPATH "/opt/SIRF-SuperBuild/INSTALL/python"
ENV SIRF_INSTALL_PATH "/opt/SIRF-SuperBuild/INSTALL"
ENV SIRF_EXERCISES_DATA_PATH "/mnt/materials/SIRF/Fully3D/SIRF/"
ENV SIRF_PATH "/opt/SIRF-SuperBuild/sources/SIRF"
#Suppress output from Gadgetron which gives some problems on notebooks (QUIERO)
ENV GADGETRON_LOG_MASK ""
RUN echo $PATH
USER root
RUN echo "export OMP_NUM_THREADS=\$(python -c 'import multiprocessing as mc; print(mc.cpu_count() // 2)')" > /usr/local/bin/before-notebook.d/omp_num_threads.sh

# switch back to
USER jovyan

#/opt/SIRF-SuperBuild/INSTALL/lib:/opt/SIRF-SuperBuild/INSTALL/lib64:/usr/local/nvidia/lib:/usr/local/nvidia/lib64::/opt/conda/lib
