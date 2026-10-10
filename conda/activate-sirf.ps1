# Runtime env (PowerShell twin of activate-sirf.sh): SIRF_INSTALL_PATH for
# examples_data_path(), GADGETRON_HOME for the Gadgetron relay config.
$env:SIRF_INSTALL_PATH = $env:CONDA_PREFIX
$env:GADGETRON_HOME = $env:CONDA_PREFIX
