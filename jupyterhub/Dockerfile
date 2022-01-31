ARG BASE_IMAGE=ubuntu:18.04
# paskino/jupyter   datascience-notebook-cuda11
FROM ${BASE_IMAGE} as base

RUN conda install cil cil-astra tigre cudatoolkit=9.2 -c conda-forge -c intel -c astra-toolbox/label/dev -c ccpi

# https://docs.docker.com/develop/develop-images/multistage-build/#use-an-external-image-as-a-stage
# not documented in https://docs.docker.com/engine/reference/builder/#copy
# FROM --from=nginx:latest /etc/nginx/nginx.conf /nginx.conf
COPY --from=synerbi/sirf:sirf-core /opt/SIRF-SuperBuild/INSTALL /opt/SIRF-SuperBuild/INSTALL/
COPY sirf_env.sh .
RUN bash sirf_env.sh && rm sirf_env.sh
