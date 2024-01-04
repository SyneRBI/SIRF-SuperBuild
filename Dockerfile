# syntax=docker/dockerfile:1
ARG BASE_CONTAINER=quay.io/jupyter/scipy-notebook:latest
FROM ${BASE_CONTAINER} as base

USER root

# suppress warnings
ENV DEBIAN_FRONTEND noninteractive
COPY docker/raw-ubuntu.sh /opt/scripts/
RUN bash /opt/scripts/raw-ubuntu.sh
#ENV LC_ALL en_GB.UTF-8
ENV LANG en_GB.UTF-8
ENV LANGUAGE en_GB:en

FROM base as build

COPY docker/update_nvidia_keys.sh /opt/scripts/
RUN bash /opt/scripts/update_nvidia_keys.sh

COPY docker/build_essential-ubuntu.sh /opt/scripts/
RUN bash /opt/scripts/build_essential-ubuntu.sh

COPY docker/build_gadgetron-ubuntu.sh /opt/scripts/
RUN bash /opt/scripts/build_gadgetron-ubuntu.sh

# SIRF external deps
COPY docker/build_system-ubuntu.sh /opt/scripts/
RUN bash /opt/scripts/build_system-ubuntu.sh

# SIRF python deps
COPY docker/requirements.yml /opt/scripts/docker-requirements.yaml
# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html#conda-environments
RUN mamba env update -n base -f /opt/scripts/docker-requirements.yaml \
 && mamba clean --all -f -y && fix-permissions "${CONDA_DIR}" /home/${NB_USER}

# ccache
COPY --link docker/devel/.ccache/ /opt/ccache/
RUN ccache -o cache_dir=/opt/ccache
ENV PATH="/usr/lib/ccache:${PATH}"

# SIRF-SuperBuild config
ARG SIRF_SB_URL="https://github.com/SyneRBI/SIRF-SuperBuild"
ARG SIRF_SB_TAG="master"
ARG REMOVE_BUILD_FILES=0
ARG RUN_CTEST=1
ARG NUM_PARALLEL_BUILDS=" "
# CMake options
ARG CMAKE_BUILD_TYPE="Release"
ARG STIR_ENABLE_OPENMP="ON"
ARG USE_SYSTEM_ACE="ON"
ARG USE_SYSTEM_Armadillo="ON"
ARG USE_SYSTEM_Boost="ON"
ARG USE_SYSTEM_FFTW3="ON"
ARG USE_SYSTEM_HDF5="OFF"
ARG USE_ITK="ON"
ARG USE_SYSTEM_SWIG="ON"
ARG USE_NiftyPET="OFF"
ARG BUILD_siemens_to_ismrmrd="ON"
ARG BUILD_pet_rd_tools="ON"
ARG Gadgetron_USE_CUDA="ON"
ARG BUILD_CIL="OFF"
ARG EXTRA_BUILD_FLAGS=""

# build, install in /opt/SIRF-SuperBuild/{INSTALL,sources/SIRF}, test (if RUN_CTEST)
COPY docker/user_sirf-ubuntu.sh /opt/scripts/
RUN BUILD_FLAGS="\
 -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}\
 -DSTIR_ENABLE_OPENMP=${STIR_ENABLE_OPENMP}\
 -DUSE_SYSTEM_ACE=${USE_SYSTEM_ACE}\
 -DUSE_SYSTEM_Armadillo=${USE_SYSTEM_Armadillo}\
 -DUSE_SYSTEM_Boost=${USE_SYSTEM_Boost}\
 -DUSE_SYSTEM_FFTW3=${USE_SYSTEM_FFTW3}\
 -DUSE_SYSTEM_HDF5=${USE_SYSTEM_HDF5}\
 -DUSE_ITK=${USE_ITK}\
 -DUSE_SYSTEM_SWIG=${USE_SYSTEM_SWIG}\
 -DUSE_NiftyPET=${USE_NiftyPET}\
 -DBUILD_siemens_to_ismrmrd=${BUILD_siemens_to_ismrmrd}\
 -DBUILD_pet_rd_tools=${BUILD_pet_rd_tools}\
 -DGadgetron_USE_CUDA=${Gadgetron_USE_CUDA}\
 -DBUILD_CIL=${BUILD_CIL}" \
 EXTRA_BUILD_FLAGS="${EXTRA_BUILD_FLAGS}" \
 bash /opt/scripts/user_sirf-ubuntu.sh \
 && fix-permissions /opt/SIRF-SuperBuild /opt/ccache

FROM base as sirf

# X11 forwarding
RUN apt update -qq && apt install -yq --no-install-recommends \
  libx11-xcb1 \
  && apt clean
RUN mkdir -p /usr/share/X11/xkb
RUN [ -e /usr/bin/X ] || ln -s /usr/bin/Xorg /usr/bin/X

RUN echo "export OMP_NUM_THREADS=\$(python -c 'import multiprocessing as mc; print(mc.cpu_count() // 2)')" > /usr/local/bin/before-notebook.d/omp_num_threads.sh

COPY --chown=${NB_USER} --chmod=644 --link docker/.bashrc /home/${NB_USER}/
# RUN sed -i s:PYTHON_INSTALL_DIR:${CONDA_DIR}:g /home/${NB_USER}/.bashrc

# install /opt/{SIRF-Exercises,CIL-Demos}
COPY docker/user_service-ubuntu.sh /opt/scripts/
RUN bash /opt/scripts/user_service-ubuntu.sh \
 && fix-permissions /opt/SIRF-Exercises /opt/CIL-Demos "${CONDA_DIR}" /home/${NB_USER}

# install from build
COPY --from=build --link --chown=${NB_USER} /opt/SIRF-SuperBuild/INSTALL/ /opt/SIRF-SuperBuild/INSTALL/
#COPY --from=build --link --chown=${NB_USER} /opt/SIRF-SuperBuild/sources/SIRF/ /opt/SIRF-SuperBuild/sources/SIRF/
#COPY --from=build --link /opt/conda/ /opt/conda/
COPY docker/requirements.yml /opt/scripts/docker-requirements.yaml
RUN mamba env update -n base -f /opt/scripts/docker-requirements.yaml \
 && mamba clean --all -f -y && fix-permissions "${CONDA_DIR}" /home/${NB_USER}

# Set environment variables for SIRF
ENV PATH "/opt/conda/bin:/opt/SIRF-SuperBuild/INSTALL/bin:$PATH"
ENV LD_LIBRARY_PATH "/opt/SIRF-SuperBuild/INSTALL/lib:/opt/SIRF-SuperBuild/INSTALL/lib64:$LD_LIBRARY_PATH"
#/usr/local/nvidia/lib:/usr/local/nvidia/lib64:/opt/conda/lib
ENV PYTHONPATH "/opt/SIRF-SuperBuild/INSTALL/python"
ENV SIRF_INSTALL_PATH "/opt/SIRF-SuperBuild/INSTALL"
ENV SIRF_PATH "/opt/SIRF-SuperBuild/sources/SIRF"
#ENV SIRF_EXERCISES_DATA_PATH "/mnt/materials/SIRF/Fully3D/SIRF/"
# Suppress output from Gadgetron which gives some problems on notebooks (QUIERO)
ENV GADGETRON_LOG_MASK ""

USER ${NB_UID}
ENV DEBIAN_FRONTEND ''
ENV DOCKER_STACKS_JUPYTER_CMD="notebook"
ENV RESTARTABLE="yes"

# TODO: CMD ["jupyterhub/service.sh"]
