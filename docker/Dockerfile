FROM ubuntu:16.04
MAINTAINER Casper da Costa-Luis <imaging@caspersci.uk.to>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get upgrade -y --no-install-recommends

# Set locale, suppress warnings
RUN apt-get update && apt-get install -y apt-utils locales
RUN locale-gen en_GB.UTF-8
#ENV LC_ALL en_GB.UTF-8
ENV LANG en_GB.UTF-8
ENV LANGUAGE en_GB:en
#RUN localectl set-locale LANG="en_GB.UTF-8"

ADD build_essential-ubuntu.sh .
RUN bash build_essential-ubuntu.sh
RUN rm build_essential-ubuntu.sh

# Python (build)
ADD build_python-ubuntu.sh .
RUN bash build_python-ubuntu.sh
RUN rm build_python-ubuntu.sh

# Gadgetron
ADD build_gadgetron-ubuntu.sh .
RUN bash build_gadgetron-ubuntu.sh
RUN rm build_gadgetron-ubuntu.sh

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

# Python (virtualenv)
ADD user_python-ubuntu.sh .
RUN bash user_python-ubuntu.sh
RUN rm user_python-ubuntu.sh

ADD .bashrc .
ADD .profile .
RUN sudo chown $mainUser .bashrc .profile
RUN sudo chgrp $mainUser .bashrc .profile
RUN sudo chmod 644 .bashrc .profile

# SIRF
ADD user_sirf-ubuntu.sh .
RUN bash --login user_sirf-ubuntu.sh
RUN rm user_sirf-ubuntu.sh

RUN sudo apt-get clean

ENV DEBIAN_FRONTEND ''

CMD cd $HOME && /bin/bash --init-file .profile
