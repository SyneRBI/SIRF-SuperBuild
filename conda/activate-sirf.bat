@echo off
:: Runtime env (conda-adapted from env_sirf.sh.in; Windows twin of activate-sirf.sh):
:: SIRF_INSTALL_PATH for examples_data_path(), GADGETRON_HOME for the Gadgetron relay config.
set "SIRF_INSTALL_PATH=%CONDA_PREFIX%"
set "GADGETRON_HOME=%CONDA_PREFIX%"
