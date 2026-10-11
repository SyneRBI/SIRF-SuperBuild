# Undo activate-sirf.ps1.
Remove-Item Env:SIRF_INSTALL_PATH -ErrorAction SilentlyContinue
Remove-Item Env:GADGETRON_HOME -ErrorAction SilentlyContinue
