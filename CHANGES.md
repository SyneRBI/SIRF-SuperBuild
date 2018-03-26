## New in Release 1.0
 - optionally build siemens_to_ismrmrd
 - optionally build petmr_rd_tools
 - major [restructuring](https://github.com/CCPPETMR/SIRF-SuperBuild/issues/16#issuecomment-360772097) of SuperBuild build directory
 - User can specify the location of the sources via the variable `SOURCES_ROOT_DIR`
 - Updated dependency versions (STIR)
 - Defaults to `USE_SYSTEM_BOOST=ON` #63

## New in Release 0.9.1

- build specific versions of dependencies (ISMRMRD, Gadgetron, STIR, SIRF)
- run tests via CTest
