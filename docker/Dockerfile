ARG BASE_IMAGE=ubuntu:18.04
FROM ${BASE_IMAGE} as base

LABEL \
  author.name="Casper da Costa-Luis, Kris Thielemans, Edoardo Pasca"                 \
  author.email=imaging@caspersci.uk.to        \
  maintainer.email=ccppetmr@stfc.ac.uk        \
  maintainer.url=https://www.ccpsynerbi.ac.uk/  \
  source.url=https://github.com/SyneRBI/SIRF-SuperBuild/  \
  licence="MPLv2.0 (https://www.mozilla.org/en-GB/MPL/2.0/)"  \
  description="CCP SyneRBI Ubuntu"

USER root
ENV DEBIAN_FRONTEND noninteractive

COPY update_nvidia_keys.sh .
RUN bash update_nvidia_keys.sh && rm update_nvidia_keys.sh

COPY raw-ubuntu.sh .
RUN bash raw-ubuntu.sh
RUN rm raw-ubuntu.sh

# Set locale, suppress warnings
#ENV LC_ALL en_GB.UTF-8
ENV LANG en_GB.UTF-8
ENV LANGUAGE en_GB:en

FROM base as core

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

# X11 forwarding
RUN apt-get update -qq && apt-get install -yq --no-install-recommends \
  libx11-xcb1 \
  && apt-get clean
RUN mkdir -p /usr/share/X11/xkb
RUN [ -e /usr/bin/X ] || ln -s /usr/bin/Xorg /usr/bin/X

RUN apt-get update -qq && apt-get install -yq --no-install-recommends \
  gosu \
  && apt-get clean

ENV DEBIAN_FRONTEND ''
WORKDIR /home-away
COPY entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]

FROM core as sirf
LABEL description="CCP SyneRBI SIRF"

# create user jovyan (jupyterhub seems to require this name)
ARG NB_USER="jovyan"
ARG NB_GROUP="users"
# some crazy number, hopefully not conflicting
ARG NB_UID="22222"
# standard guid for users
ARG NB_GID="100"
ARG HOME="/home/${NB_USER}"
ARG PYTHON_INSTALL_DIR="/opt/conda"
ARG PYTHON_EXECUTABLE="miniconda"

ENV DEBIAN_FRONTEND noninteractive

# make /opt  writeable for all users
RUN chmod go+rwx /opt

# copy to $WORKDIR (i.e. /home-away) as this is where entrypoint.sh will pick them up
COPY .bashrc .
COPY .profile .

# Create NB_GROUP and NB_USER
RUN (addgroup --gid ${NB_GID} "${NB_GROUP}" || true) && \
    (useradd -l -m -s /bin/bash -N -u "${NB_UID}" -g "${NB_GID}" "${NB_USER}" || true)
# TODO add into sudo ? (probably not for safety)

WORKDIR ${HOME}

# copy to home of NB_USER
COPY .bashrc .
COPY .profile .
RUN chmod 644 .bashrc .profile && chown -R "${NB_USER}":"${NB_GROUP}" "${HOME}"
# update bashrc with the location of PYTHON_INSTALL_DIR
RUN sed -i s:PYTHON_INSTALL_DIR:${PYTHON_INSTALL_DIR}:g .bashrc

# run user scripts as NB_USER
USER ${NB_USER}:${NB_GROUP}

# Python (virtualenv or conda)
COPY requirements.txt .
COPY requirements_conda_forge.txt .
COPY user_python-ubuntu.sh .
RUN PYTHON_EXECUTABLE=${PYTHON_EXECUTABLE} PYTHON_INSTALL_DIR=${PYTHON_INSTALL_DIR} bash user_python-ubuntu.sh  && \
    rm user_python-ubuntu.sh requirements.txt requirements_conda_forge.txt


# ccache
USER root
COPY devel/.ccache/ /opt/ccache/
# give everyone write permisions
RUN chmod -R go+w /opt/ccache

# SIRF
USER "${NB_USER}"

RUN ccache -o cache_dir=/opt/ccache
COPY user_sirf-ubuntu.sh .

# SIRF-SuperBuild version
ARG SIRF_SB_URL="https://github.com/SyneRBI/SIRF-SuperBuild"
ARG SIRF_SB_TAG="master"
# speeding up the cmake build
# (implementation note: changing this in your environment will invalidate the docker cache sadly)
ARG NUM_PARALLEL_BUILDS="2"

ARG BUILD_FLAGS="\
 -DCMAKE_BUILD_TYPE=Release\
 -DSTIR_ENABLE_OPENMP=ON -DUSE_SYSTEM_ACE=ON\
 -DUSE_SYSTEM_Armadillo=ON -DUSE_SYSTEM_Boost=ON\
 -DUSE_SYSTEM_FFTW3=ON -DUSE_SYSTEM_HDF5=ON -DUSE_ITK=ON\
 -DGadgetron_USE_CUDA=OFF\
 -DUSE_SYSTEM_SWIG=ON\
 -DUSE_NiftyPET=OFF\
 -DBUILD_siemens_to_ismrmrd=ON -DBUILD_pet_rd_tools=ON"
ARG EXTRA_BUILD_FLAGS="-DBUILD_CIL=OFF"
RUN bash user_sirf-ubuntu.sh
RUN rm user_sirf-ubuntu.sh

# give everyone write and execute permission
RUN chmod -R go+rwX /opt/SIRF-SuperBuild/INSTALL

ENV DEBIAN_FRONTEND ''

# go back to root (entrypoint.sh will switch users)
USER root
CMD ["/bin/bash"]

FROM sirf as service

ENV DEBIAN_FRONTEND noninteractive

ARG NB_USER="jovyan"
ARG NB_GROUP="users"
ARG HOME="/home/${NB_USER}"

USER "${NB_USER}"

COPY requirements-service.txt .
COPY user_service-ubuntu.sh .
RUN bash user_service-ubuntu.sh
RUN rm user_service-ubuntu.sh requirements-service.txt

USER root
COPY download_data.sh /usr/local/bin/

COPY service.sh /usr/local/bin/
ENV DEBIAN_FRONTEND ''
CMD ["/usr/local/bin/service.sh"]

# note: remain root (entrypoint.sh will switch users)

FROM service as multi
COPY service.multi.sh /usr/local/bin/

FROM sirf as jupyterhub

ENV DEBIAN_FRONTEND noninteractive

ARG NB_USER="jovyan"
ARG NB_GROUP="users"
ARG HOME="/home/${NB_USER}"

USER root

# Install all OS dependencies for notebook server that starts but lacks all
# features (e.g., download as all possible file formats)
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    wget \
    ca-certificates \
    sudo \
    locales \
    fonts-liberation \
    run-one && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# remove some sudo permissions
RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \
    sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers && \
    sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers

# Add Tini (note: no tini apt-package yet in Ubuntu 18.04)
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# TODO install jupyterhub requirements

USER "${NB_USER}"

ENTRYPOINT ["/tini", "-g", "--"]
# TODO some stuff here
#CMD ["/usr/local/bin/service-jupyterhub.sh"]

# TODO set some env variables (or do it in a compose file)

ENV DEBIAN_FRONTEND ''
