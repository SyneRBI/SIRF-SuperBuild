FROM ccppetmr/base
LABEL \
  author.name="Casper da Costa-Luis"          \
  author.email=imaging@caspersci.uk.to        \
  maintainer.email=ccppetmr@stfc.ac.uk        \
  maintainer.url=https://www.ccppetmr.ac.uk/  \
  source.url=https://github.com/CCPPETMR/SIRF-SuperBuild/  \
  licence="MPLv2.0 (https://www.mozilla.org/en-GB/MPL/2.0/)"  \
  description="CCP PET-MR SIRF"

ENV DEBIAN_FRONTEND noninteractive

# Python (virtualenv)
COPY requirements.txt .
COPY user_python-ubuntu.sh .
RUN bash user_python-ubuntu.sh
RUN rm user_python-ubuntu.sh requirements.txt

# SIRF
COPY user_sirf-ubuntu.sh .
RUN EXTRA_BUILD_FLAGS="-DCMAKE_BUILD_TYPE=Release -DUSE_SYSTEM_Boost=ON \
  -DDEVEL_BUILD=ON -DUSE_SYSTEM_Armadillo=ON -DUSE_SYSTEM_FFTW3=ON \
  -DUSE_SYSTEM_HDF5=ON -DBUILD_siemens_to_ismrmrd=ON -DUSE_SYSTEM_SWIG=ON" \
  bash --login user_sirf-ubuntu.sh
RUN rm user_sirf-ubuntu.sh

ENV DEBIAN_FRONTEND ''

CMD cd $HOME && /bin/bash --init-file .profile
