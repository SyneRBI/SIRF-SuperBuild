FROM ubuntu:16.04
MAINTAINER Casper da Costa-Luis <imaging@caspersci.uk.to>

ENV DEBIAN_FRONTEND noninteractive

# Set locale, suppress warnings
RUN apt update && apt install -y apt-utils curl locales
RUN locale-gen en_GB.UTF-8
#ENV LC_ALL en_GB.UTF-8
ENV LANG en_GB.UTF-8
ENV LANGUAGE en_GB:en
#RUN localectl set-locale LANG="en_GB.UTF-8"

# Essential
RUN apt update && apt install -y \
  bash-completion      \
  build-essential      \
  git                  \
  g++                  \
  man                  \
  make                 \
  sudo

# CMake
RUN mkdir /opt/cmake
RUN curl -O https://cmake.org/files/v3.7/cmake-3.7.2-Linux-x86_64.sh
RUN echo y | bash cmake-3.7.2-Linux-x86_64.sh --prefix=/opt/cmake
RUN rm cmake-3.7.2-Linux-x86_64.sh

# Python
RUN apt update && apt install -y \
  python-dev           \
  python-matplotlib

# Gadgetron
RUN apt update && apt install -y \
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
RUN sudo apt update && sudo apt install -y libx11-xcb1
RUN sudo mkdir -p /usr/share/X11/xkb
RUN [ -e /usr/bin/X ] || ln -s /usr/bin/Xorg /usr/bin/X

ARG mainUser=sirfuser
RUN addgroup --system $mainUser
RUN adduser --home /home/$mainUser --shell /bin/bash --system --ingroup $mainUser $mainUser

#RUN echo "$mainUser:x:${uid}:${gid}:$mainUser,,,:/home/$mainUser:/bin/bash" >> /etc/passwd
RUN echo "$mainUser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/$mainUser

USER $mainUser
ENV HOME /home/$mainUser
WORKDIR $HOME

# CMake path
RUN echo 'export PATH=/opt/cmake/cmake-3.7.2-Linux-x86_64/bin:$PATH' >> .bashrc

# git completion
RUN curl -O https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
RUN echo '. ~/git-prompt.sh' >> .bashrc
RUN echo '[ -f ~/.bash_aliases ] && . ~/.bash_aliases' >> .bashrc
RUN echo 'if [ -n "$BASH_VERSION" ]; then if [ -f "$HOME/.bashrc" ]; then . "$HOME/.bashrc"; fi; fi' >> .profile

# Python
RUN curl -O https://bootstrap.pypa.io/get-pip.py
RUN sudo -H python get-pip.py
RUN rm get-pip.py
RUN sudo -H python -m pip install -U pip virtualenv
RUN virtualenv py2
ARG PIPINST="$HOME/py2/bin/pip install -U"
RUN echo '. ~/py2/bin/activate' >> .bashrc
RUN $PIPINST cython
RUN $PIPINST docopt
RUN $PIPINST matplotlib
RUN git clone https://github.com/ismrmrd/ismrmrd-python-tools.git
RUN cd ismrmrd-python-tools && $PIPINST .
#RUN $PIPINST scipy

RUN git clone https://github.com/CCPPETMR/SIRF-SuperBuild
RUN cd SIRF-SuperBuild \
  && . ~/py2/bin/activate \
  && /opt/cmake/cmake-3.7.2-Linux-x86_64/bin/cmake . \
  && make -j8

RUN mv SIRF-SuperBuild/INSTALL/share/gadgetron/config/gadgetron.xml.example SIRF-SuperBuild/INSTALL/share/gadgetron/config/gadgetron.xml
RUN echo '. ~/SIRF-SuperBuild/INSTALL/bin/env_ccppetmr.sh' >> .bashrc

ENV DEBIAN_FRONTEND ''

CMD cd $HOME && /bin/bash --init-file .profile
