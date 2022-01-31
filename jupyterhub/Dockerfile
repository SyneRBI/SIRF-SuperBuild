ARG BASE_IMAGE=ubuntu:18.04
# paskino/jupyter   datascience-notebook-cuda11
FROM ${BASE_IMAGE} as base

RUN conda install cil cil-astra tigre cudatoolkit=9.2 -c conda-forge -c intel -c astra-toolbox/label/dev -c ccpi

# https://docs.docker.com/develop/develop-images/multistage-build/#use-an-external-image-as-a-stage
# not documented in https://docs.docker.com/engine/reference/builder/#copy
# FROM --from=nginx:latest /etc/nginx/nginx.conf /nginx.conf
COPY --from=synerbi/sirf:sirf-core /opt/SIRF-SuperBuild/INSTALL/python /opt/conda/lib/python3.9/site-packages/
COPY --from=synerbi/sirf:sirf-core /opt/SIRF-SuperBuild/INSTALL/bin /opt/conda/bin
COPY --from=synerbi/sirf:sirf-core /opt/SIRF-SuperBuild/INSTALL/lib /opt/conda/lib
COPY --from=synerbi/sirf:sirf-core /opt/SIRF-SuperBuild/INSTALL/include /opt/conda/include
COPY --from=synerbi/sirf:sirf-core /opt/SIRF-SuperBuild/INSTALL/share /opt/conda/share

# COPY sirf_env.sh .
# RUN bash sirf_env.sh && rm sirf_env.sh
