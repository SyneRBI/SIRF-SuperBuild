FROM ubuntu:16.04
LABEL \
  author.name="Casper da Costa-Luis"          \
  author.email=imaging@caspersci.uk.to        \
  maintainer.email=ccppetmr@stfc.ac.uk        \
  maintainer.url=https://www.ccppetmr.ac.uk/  \
  source.url=https://github.com/CCPPETMR/SIRF-SuperBuild/  \
  licence="MPLv2.0 (https://www.mozilla.org/en-GB/MPL/2.0/)"  \
  description="CCP PET-MR SIRF"

ENV DEBIAN_FRONTEND noninteractive

# Set locale, suppress warnings
RUN apt-get update && apt-get install -y apt-utils locales
RUN locale-gen en_GB.UTF-8
#ENV LC_ALL en_GB.UTF-8
ENV LANG en_GB.UTF-8
ENV LANGUAGE en_GB:en
#RUN localectl set-locale LANG="en_GB.UTF-8"

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
RUN apt-get update && apt-get install -y --no-install-recommends libx11-xcb1
RUN sudo mkdir -p /usr/share/X11/xkb
RUN [ -e /usr/bin/X ] || ln -s /usr/bin/Xorg /usr/bin/X

ARG mainUser=sirfuser
ARG UID=1000
ARG GROUPS=1000
RUN addgroup --system --gid "$GROUPS" "$mainUser"
RUN adduser --home /home/"$mainUser" --shell /bin/bash --system --ingroup "$mainUser" --uid "$UID" "$mainUser"
#RUN echo "$mainUser:x:${uid}:${gid}:$mainUser,,,:/home/$mainUser:/bin/bash" >> /etc/passwd

RUN echo "$mainUser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/"$mainUser"

USER "$mainUser"
ENV HOME /home/"$mainUser"
WORKDIR $HOME

# Python (virtualenv)
COPY user_python-ubuntu.sh .
RUN bash user_python-ubuntu.sh
RUN rm user_python-ubuntu.sh

COPY .bashrc .
COPY .profile .
RUN sudo chown "$mainUser" .bashrc .profile
RUN sudo chgrp "$mainUser" .bashrc .profile
RUN sudo chmod 644 .bashrc .profile

# SIRF
COPY user_sirf-ubuntu.sh .
RUN EXTRA_BUILD_FLAGS="-DCMAKE_BUILD_TYPE=Release -DUSE_SYSTEM_Boost=ON \
  -DUSE_SYSTEM_SWIG=ON -DUSE_SYSTEM_HDF5=ON -DUSE_SYSTEM_FFTW3=ON \
  -DUSE_SYSTEM_Armadillo=ON -DBUILD_STIR_EXECUTABLES=ON \
  -DBUILD_STIR_SWIG_PYTHON=ON" \
  bash --login user_sirf-ubuntu.sh
RUN rm user_sirf-ubuntu.sh

RUN sudo apt-get clean

ENV DEBIAN_FRONTEND ''

CMD cd $HOME && /bin/bash --init-file .profile
