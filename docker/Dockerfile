FROM ubuntu:16.04 as core
LABEL \
  author.name="Casper da Costa-Luis"          \
  author.email=imaging@caspersci.uk.to        \
  maintainer.email=ccppetmr@stfc.ac.uk        \
  maintainer.url=https://www.ccppetmr.ac.uk/  \
  source.url=https://github.com/CCPPETMR/SIRF-SuperBuild/  \
  licence="MPLv2.0 (https://www.mozilla.org/en-GB/MPL/2.0/)"  \
  description="CCP PET-MR Ubuntu"

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

## end of core ##

FROM ccppetmr/sirf:core as sirf
LABEL description="CCP PET-MR SIRF"

ENV DEBIAN_FRONTEND noninteractive

COPY .bashrc .
COPY .profile .
RUN chmod 644 .bashrc .profile

# Python (virtualenv)
COPY requirements.txt .
COPY user_python-ubuntu.sh .
RUN bash user_python-ubuntu.sh
RUN rm user_python-ubuntu.sh requirements.txt

# SIRF
COPY user_sirf-ubuntu.sh .
COPY devel/.ccache/ /opt/ccache/
RUN ccache -o cache_dir=/opt/ccache
ARG BUILD_FLAGS="\
  -DCMAKE_BUILD_TYPE=Release \
  -DUSE_SYSTEM_Armadillo=ON -DUSE_SYSTEM_Boost=ON -DUSE_SYSTEM_FFTW3=ON \
  -DUSE_SYSTEM_HDF5=ON -DBUILD_siemens_to_ismrmrd=ON -DUSE_SYSTEM_SWIG=ON"
ARG EXTRA_BUILD_FLAGS=""
RUN bash user_sirf-ubuntu.sh
RUN rm user_sirf-ubuntu.sh

RUN mv ~/.git-prompt.sh .

ENV DEBIAN_FRONTEND ''
CMD ["/bin/bash"]
