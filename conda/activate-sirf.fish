# Runtime env (fish twin of activate-sirf.sh): SIRF_INSTALL_PATH for
# examples_data_path(), GADGETRON_HOME for the Gadgetron relay config.
set -gx SIRF_INSTALL_PATH "$CONDA_PREFIX"
set -gx GADGETRON_HOME "$CONDA_PREFIX"
