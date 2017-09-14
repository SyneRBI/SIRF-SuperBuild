FROM ubuntu:16.04
MAINTAINER Casper da Costa-Luis <imaging@caspersci.uk.to>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get upgrade -y --no-install-recommends

# Set locale, suppress warnings
RUN apt-get update && apt-get install -y apt-utils curl locales
RUN locale-gen en_GB.UTF-8
#ENV LC_ALL en_GB.UTF-8
ENV LANG en_GB.UTF-8
ENV LANGUAGE en_GB:en
#RUN localectl set-locale LANG="en_GB.UTF-8"

# Essential
RUN apt-get update && apt-get install -y --no-install-recommends \
  bash-completion      \
  build-essential      \
  git                  \
  g++                  \
  man                  \
  make                 \
  sudo

# CMake
RUN mkdir /opt/cmake
RUN curl https://cmake.org/files/v3.7/cmake-3.7.2-Linux-x86_64.sh > cmake.sh
RUN echo y | bash cmake.sh --prefix=/opt/cmake --exclude-subdir
RUN rm cmake.sh

# Python (build)
RUN apt-get update && apt-get install -y --no-install-recommends \
  python-dev           \
  python-tk

# Gadgetron
RUN apt-get update && apt-get install -y --no-install-recommends \
  h5utils              \
  liblapack-dev        \
  libace-dev
# Not required (yet) by SIRF
# libxml2-dev
# libxslt-dev
# python-h5py
# python-libxml2
# python-psutil
# libplplot-dev

# X11 forwarding
RUN apt-get update && apt-get install -y --no-install-recommends libx11-xcb1
RUN sudo mkdir -p /usr/share/X11/xkb
RUN [ -e /usr/bin/X ] || ln -s /usr/bin/Xorg /usr/bin/X

ARG mainUser=sirfuser
ARG UID=1000
ARG GROUPS=1000
RUN addgroup --system --gid $GROUPS $mainUser
RUN adduser --home /home/$mainUser --shell /bin/bash --system --ingroup $mainUser --uid $UID $mainUser
#RUN echo "$mainUser:x:${uid}:${gid}:$mainUser,,,:/home/$mainUser:/bin/bash" >> /etc/passwd

RUN echo "$mainUser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/$mainUser

USER $mainUser
ENV HOME /home/$mainUser
WORKDIR $HOME

# git completion
RUN curl -O https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh

# Python (virtualenv)
RUN curl -O https://bootstrap.pypa.io/get-pip.py
RUN sudo -H python get-pip.py
RUN rm get-pip.py
RUN sudo -H python -m pip install -U pip virtualenv
RUN virtualenv py2
ARG PIPINST="$HOME/py2/bin/pip install -U"
RUN $PIPINST cython

RUN git clone https://github.com/CCPPETMR/SIRF-SuperBuild
WORKDIR $HOME/SIRF-SuperBuild
RUN . ~/py2/bin/activate \
  && /opt/cmake/bin/cmake .
RUN make -j

RUN mv INSTALL/share/gadgetron/config/gadgetron.xml.example INSTALL/share/gadgetron/config/gadgetron.xml
WORKDIR $HOME

# Python (runtime)
RUN $PIPINST docopt
RUN $PIPINST matplotlib
#RUN $PIPINST scipy
RUN git clone https://github.com/ismrmrd/ismrmrd-python-tools.git
RUN cd ismrmrd-python-tools && $PIPINST .

ADD .bashrc .
ADD .profile .
RUN sudo chown $mainUser .bashrc .profile
RUN sudo chgrp $mainUser .bashrc .profile
RUN sudo chmod 644 .bashrc .profile

RUN sudo apt-get clean

ENV DEBIAN_FRONTEND ''

CMD cd $HOME && /bin/bash --init-file .profile
