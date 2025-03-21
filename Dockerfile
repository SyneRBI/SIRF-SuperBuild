# syntax=docker/dockerfile:1
ARG BASE_CONTAINER=quay.io/jupyter/scipy-notebook:ubuntu-22.04
FROM ${BASE_CONTAINER} as base

USER root

# suppress warnings
ENV DEBIAN_FRONTEND noninteractive
COPY docker/raw-ubuntu.sh /opt/scripts/
RUN bash /opt/scripts/raw-ubuntu.sh
#ENV LC_ALL en_GB.UTF-8
ENV LANG en_GB.UTF-8
ENV LANGUAGE en_GB:en

COPY docker/build_gadgetron-ubuntu.sh /opt/scripts/
RUN bash /opt/scripts/build_gadgetron-ubuntu.sh

# SIRF external deps
COPY docker/build_system-ubuntu.sh /opt/scripts/
RUN bash /opt/scripts/build_system-ubuntu.sh

# SIRF python deps
ARG BUILD_GPU=0
ARG BUILD_CIL="OFF"
COPY docker/requirements.yml /opt/scripts/
# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html#conda-environments
# https://github.com/TomographicImaging/CIL/blob/master/Dockerfile
# If BUILD_CIL is OFF, remove the IPP dependency
# https://github.com/SyneRBI/SIRF-SuperBuild/issues/935

FROM base as temp
RUN if test "$BUILD_GPU" != 0; then \
  sed -ri 's/^(\s*)#\s*(- \S+.*#.*GPU.*)$/\1\2/' /opt/scripts/requirements.yml; \
 fi\
 && if test "$BUILD_CIL" != "OFF"; then \ 
   sed -r -i -e '/^\s*- (cil|ccpi-regulariser).*/d' /opt/scripts/requirements.yml; \
 fi
FROM temp as temp2

RUN conda config --env --set channel_priority strict \
 && for ch in defaults ccpi conda-forge; do conda config --env --add channels $ch; done \
 && mamba env update -n base -f /opt/scripts/requirements.yml \
 && mamba clean --all -f -y && fix-permissions "${CONDA_DIR}" /home/${NB_USER}

RUN conda list

COPY docker/update_nvidia_keys.sh /opt/scripts/
RUN bash /opt/scripts/update_nvidia_keys.sh

COPY docker/build_essential-ubuntu.sh /opt/scripts/
RUN bash /opt/scripts/build_essential-ubuntu.sh

# ccache
COPY --link docker/devel/.ccache/ /opt/ccache/
RUN ccache -o cache_dir=/opt/ccache
# ENV PATH="/usr/lib/ccache:${PATH}"

# SIRF-SuperBuild config
COPY ./.git /opt/SIRF-SuperBuild.git
ARG SIRF_SB_URL="file:///opt/SIRF-SuperBuild.git"
ARG SIRF_SB_TAG="HEAD"
ARG REMOVE_BUILD_FILES=0
ARG RUN_CTEST=1
ARG NUM_PARALLEL_BUILDS=" "
# CMake options
ARG CMAKE_BUILD_TYPE="Release"
ARG STIR_ENABLE_OPENMP="ON"
ARG USE_SYSTEM_Armadillo="ON"
ARG USE_SYSTEM_ACE="OFF"
ARG USE_SYSTEM_Boost="ON"
ARG USE_SYSTEM_FFTW3="OFF"
ARG USE_SYSTEM_HDF5="ON"
ARG USE_ITK="ON"
ARG USE_SYSTEM_SWIG="ON"
ARG USE_NiftyPET="OFF"
ARG USE_SYSTEM_ITK="ON"
ARG USE_SYSTEM_parallelproj="ON"
ARG USE_SYSTEM_SWIG="ON"
ARG USE_SYSTEM_NIFTYREG="ON"
ARG USE_SYSTEM_GTest="ON"
ARG USE_SYSTEM_range-v3="ON"
ARG USE_SYSTEM_Date="ON"
ARG BUILD_siemens_to_ismrmrd="ON"
ARG BUILD_pet_rd_tools="ON"
ARG Gadgetron_USE_MKL="ON"
ARG Gadgetron_USE_CUDA="ON"
# Build arguments defined in the previous stage
ARG BUILD_CIL
ARG EXTRA_BUILD_FLAGS=""

# build, install in /opt/SIRF-SuperBuild/{INSTALL,sources/SIRF}, test (if RUN_CTEST)
COPY docker/user_sirf-ubuntu.sh /opt/scripts/

FROM temp2 as build


RUN BUILD_FLAGS="-G Ninja\
 -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}\
 -DSTIR_ENABLE_OPENMP=${STIR_ENABLE_OPENMP}\
 -DUSE_ITK=${USE_ITK}\
 -DBUILD_siemens_to_ismrmrd=${BUILD_siemens_to_ismrmrd}\
 -DBUILD_pet_rd_tools=${BUILD_pet_rd_tools}\
 -DGadgetron_USE_CUDA=${Gadgetron_USE_CUDA}\
 -DBUILD_CIL=${BUILD_CIL}\
 -DUSE_SYSTEM_Armadillo=${USE_SYSTEM_Armadillo}\
 -DUSE_SYSTEM_Boost=${USE_SYSTEM_Boost}\
 -DUSE_SYSTEM_FFTW3=${USE_SYSTEM_FFTW3}\
 -DUSE_SYSTEM_HDF5=${USE_SYSTEM_HDF5}\
 -DUSE_SYSTEM_SWIG=${USE_SYSTEM_SWIG}\
 -DUSE_NiftyPET=${USE_NiftyPET}\
 -DUSE_SYSTEM_ITK=${USE_SYSTEM_ITK}\
 -DUSE_SYSTEM_parallelproj=${USE_SYSTEM_parallelproj}\
 -DUSE_SYSTEM_SWIG=${USE_SYSTEM_SWIG}\
 -DUSE_SYSTEM_NIFTYREG=${USE_SYSTEM_NIFTYREG}\
 -DUSE_SYSTEM_GTest=${USE_SYSTEM_GTest}\
 -DUSE_SYSTEM_range-v3=${USE_SYSTEM_range-v3}\
 -DUSE_SYSTEM_Date=${USE_SYSTEM_Date}\
 -DGadgetron_USE_MKL=${Gadgetron_USE_MKL}"\
 EXTRA_BUILD_FLAGS="${EXTRA_BUILD_FLAGS}" \
 bash /opt/scripts/user_sirf-ubuntu.sh \
 && fix-permissions /opt/SIRF-SuperBuild /opt/ccache

FROM base as sirf

# X11 forwarding
RUN apt update -qq && apt install -yq --no-install-recommends \
  libx11-xcb1 \
  && apt clean \
  && mkdir -p /usr/share/X11/xkb \
  && test -e /usr/bin/X || ln -s /usr/bin/Xorg /usr/bin/X

RUN echo 'test -z "$OMP_NUM_THREADS" && export OMP_NUM_THREADS=$(python -c "import multiprocessing as mc; print(max(1, mc.cpu_count() - 2))")' > /usr/local/bin/before-notebook.d/omp_num_threads.sh

COPY --chown=${NB_USER} --chmod=644 --link docker/.bashrc /home/${NB_USER}/
# RUN sed -i s:PYTHON_INSTALL_DIR:${CONDA_DIR}:g /home/${NB_USER}/.bashrc

# install from build
COPY --from=build --link --chown=${NB_USER} /opt/SIRF-SuperBuild/INSTALL/ /opt/SIRF-SuperBuild/INSTALL/
#COPY --from=build --link --chown=${NB_USER} /opt/SIRF-SuperBuild/sources/SIRF/ /opt/SIRF-SuperBuild/sources/SIRF/
#COPY --from=build --link /opt/conda/ /opt/conda/

# install {SIRF-Exercises,CIL-Demos}
ARG BUILD_CIL
COPY docker/user_demos.sh /opt/scripts/
RUN BUILD_CIL="${BUILD_CIL}" bash /opt/scripts/user_demos.sh \
 && fix-permissions /opt/SIRF-Exercises /opt/CIL-Demos "${CONDA_DIR}" /home/${NB_USER}

# docker-stacks notebook
USER ${NB_UID}
ENV DEBIAN_FRONTEND ''
#ENV DOCKER_STACKS_JUPYTER_CMD="notebook"
ENV RESTARTABLE="yes"
#ENV USE_HTTPS="yes"
# gadgetron
EXPOSE 9002
ENV GADGETRON_RELAY_HOST="0.0.0.0"

# run gadgetron in the background before start-notebook.py
COPY --link --chown=${NB_USER} docker/start-gadgetron-notebook.sh /opt/scripts/
# COPY --from=build --link --chown=${NB_USER} /opt/SIRF-SuperBuild/INSTALL/lib /opt/conda/lib
COPY --from=build --link --chown=${NB_USER} /opt/SIRF-SuperBuild/INSTALL/bin/env_sirf.sh /opt/conda/etc/conda/activate.d
CMD ["/opt/scripts/start-gadgetron-notebook.sh"]
