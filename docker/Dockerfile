ARG BASE_IMAGE=ubuntu:18.04
FROM ${BASE_IMAGE} as base

LABEL \
  author.name="Casper da Costa-Luis"          \
  author.name="Edoardo Pasca"                 \
  author.email=imaging@caspersci.uk.to        \
  maintainer.email=ccppetmr@stfc.ac.uk        \
  maintainer.url=https://www.ccpsynerbi.ac.uk/  \
  source.url=https://github.com/SyneRBI/SIRF-SuperBuild/  \
  licence="MPLv2.0 (https://www.mozilla.org/en-GB/MPL/2.0/)"  \
  description="CCP SyneRBI Ubuntu"


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
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen
    # tini \
    


ENV DEBIAN_FRONTEND noninteractive

COPY raw-ubuntu.sh .
RUN bash raw-ubuntu.sh
RUN rm raw-ubuntu.sh

# Set locale, suppress warnings
#ENV LC_ALL en_GB.UTF-8
ENV LANG en_GB.UTF-8
ENV LANGUAGE en_GB:en

# create user jovyan
ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"
ARG HOME="/home/${NB_USER}" 
# Copy a script that we will use to correct permissions after running certain commands
COPY fix-permissions /usr/local/bin/fix-permissions
RUN chmod a+rx /usr/local/bin/fix-permissions
# Create NB_USER with name jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \
    sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers && \
    sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers && \
    useradd -l -m -s /bin/bash -N -u "${NB_UID}" "${NB_USER}" && \
    chmod g+w /etc/passwd && \
    fix-permissions "${HOME}"

RUN echo "${NB_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/"${NB_USER}"

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

# COPY entrypoint.sh /usr/local/bin/
# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# CMD ["/bin/bash"]

FROM core as sirf

LABEL description="CCP SyneRBI SIRF"

ENV DEBIAN_FRONTEND noninteractive

COPY .bashrc .
COPY .profile .
RUN chmod 644 .bashrc .profile

# Python (virtualenv)
COPY requirements.txt .
COPY requirements_conda_forge.txt .
COPY user_python-ubuntu.sh .
RUN bash user_python-ubuntu.sh && \
    rm user_python-ubuntu.sh requirements.txt requirements_conda_forge.txt
COPY ls_dir.sh .
RUN bash ls_dir.sh
# create user jovyan
ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"
ARG HOME="/home/${NB_USER}" 
RUN fix-permissions "/opt/pyvenv"

# Build SIRF as jovyan
WORKDIR /home/jovyan

COPY user_sirf-ubuntu.sh .
COPY user_sirf-ubuntu_ITKBOOSTSTIR.sh .
COPY user_sirf-ubuntu_Gadgetron.sh .
COPY devel/.ccache/ /opt/ccache/
RUN ccache -o cache_dir=/opt/ccache

# Switch to jovyan
# USER ${NB_UID} 
ARG BUILD_FLAGS="\
 -DCMAKE_BUILD_TYPE=Release\
 -DBUILD_STIR_WITH_OPENMP=ON -DUSE_SYSTEM_ACE=ON\
 -DUSE_SYSTEM_Armadillo=ON -DUSE_SYSTEM_Boost=ON -DBUILD_CIL=ON\
 -DUSE_SYSTEM_FFTW3=ON -DUSE_SYSTEM_HDF5=ON -DUSE_ITK=ON\
 -DUSE_SYSTEM_SWIG=ON\
 -DUSE_NiftyPET=OFF\
 -DUSE_SYSTEM_HDF5=ON\
 -DBUILD_siemens_to_ismrmrd=ON -DBUILD_pet_rd_tools=ON"
ARG EXTRA_BUILD_FLAGS=""
RUN bash user_sirf-ubuntu_ITKBOOSTSTIR.sh
RUN rm user_sirf-ubuntu_ITKBOOSTSTIR.sh

RUN bash user_sirf-ubuntu_Gadgetron.sh
RUN rm user_sirf-ubuntu_Gadgetron.sh

RUN bash user_sirf-ubuntu.sh
RUN rm user_sirf-ubuntu.sh

RUN fix-permissions "/opt/"
# RUN mv ~/.git-prompt.sh .

ENV DEBIAN_FRONTEND ''
CMD ["/bin/bash"]

FROM sirf as service
# create user jovyan
ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"
ARG HOME="/home/${NB_USER}" 
# switch back to root to install
USER root

ENV DEBIAN_FRONTEND noninteractive

COPY requirements-service.txt .
# install jupyterhub-singleuser
COPY requirements-service-jupyterhub.txt .
COPY user_service-ubuntu.sh .
RUN bash user_service-ubuntu.sh
RUN rm user_service-ubuntu.sh requirements-service.txt

COPY download_data.sh /usr/local/bin/

COPY service.sh /usr/local/bin/


ENV DEBIAN_FRONTEND ''

WORKDIR ${HOME}
COPY .bashrc .
COPY .profile .
COPY create_jupyter_notebook_config.sh .
RUN chmod 644 .bashrc .profile &&\
    chown ${NB_UID}:${NB_GID} .bashrc &&\
    chown ${NB_UID}:${NB_GID} .profile &&\
    bash create_jupyter_notebook_config.sh &&\
    fix-permissions ".jupyter" && \
    fix-permissions ".ccache" && \
    fix-permissions ".conda" && \
    fix-permissions ".cmake" && \
    fix-permissions /opt/SIRF-SuperBuild/INSTALL


# Switch back to jovyan to avoid accidental container runs as root
USER ${NB_UID} 
ENV PATH "/opt/pyvenv/bin:$PATH"
RUN echo $PATH

CMD ["/usr/local/bin/service.sh"]

FROM service as multi
# create user jovyan
ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"
ARG HOME="/home/${NB_USER}" 
COPY service.multi.sh /usr/local/bin/



