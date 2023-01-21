# ChangeLog
## v3.4.0
- Removed CIL-ASTRA as it has been merged into CIL code base.
- Added python-opencv , pytest, pytest-cov and coverage to docker requirements.txt
- docker images updates
  - Ubuntu: 22.04
  - added requirements.yml and requirements-service.yml to handle dependencies for conda python
  - updates to use mamba
  - use jupyterlab as opposed to notebook in the "service" images
  - CMake: v3.25.1
- VM updates
  - Ubuntu: 22.04
  - update configuration and documentation to use jupyterlab as opposed to the notebook server
  - CMake: 3.21.3
  - fixes documentation
  - use the VMSVGA graphics controller
- updated versions:
  - SIRF: v3.4.0
  - CIL: a6062410028c9872c5b355be40b96ed1497fed2a > 22.1.0
  - GTest: 1.12.1
  - glog: 0.6.0
  - parallelproj: v1.2.13
  - STIR: rel_5.1.0
  - Boost: 1.78.0

## v3.3.1
- VM: 
   - "update_VM.sh -s" (i.e. "UPDATE.sh -s") no longer runs configure_gnome.sh. If you have a very old VM, run it manually instead.
   - Updates to run using docker scripts
   - installs custom pip and all python prerequisites with pip
   - Bugfix in finding cython and python in UPDATE.sh
   - general refresh of scripts etc
   - move `zero_fill.sh` from `first_run.sh` and move it to a new `clean_before_VM_export.sh` script, which also removes build files to make the exported VM smaller.
- docker and VM:
   - install `uuid-dev` such that we're prepared for installing ROOT
   - no longer force numpy<=1.20
- CMake:
   - FindCython allows hints
   
## v3.3.0
- known problems:
   - VM and jupyterhub scripts need merging various fixes
- gemeric *.cmake fixes:
   - update to the ASTRA build script
   - fix/add minimum versions for various packages
   - improve finding GTest
- Windows
   - Boost build add regex and random
   - install `env_sirf.PS1` and `.bat` files (similar to the existing `.sh` and `.csh` files)
- docker:
   - fix problems with CUDA repo keys
   - minor fixes to scripts for use elsewhere (including preparation for more recent Ubuntu)
- VM: 
  - set BUILD_CIL=ON
- add CITATION.cff (and remove .zenodo.json)
- added numba as dependency in docker files
- updated versions:
  - SIRF: 3.3.0
  - STIR: 5.0.2
  - parallelproj: v0.8
  - CCPi Regularisation: v21.0.0
  - CIL: v21.4.1 (CIL devel build to commit hash ef66083de231492f9571f5512b33068f6950e877 )


## v3.2.0
- Moved the VM scripts etc to this repo
- CMake: removed USE_SYSTEM_siemens_to_ismrmrd
- CMake: added required versions for STIR, NIFTYREG, ISMRMRD.
- Drop Python 2 support
- CMake minimum required version is set to 3.16.2, as it supports Boost 1.72
- VirtualBox VM is created from the SIRF-SuperBuild repository
- Docker images install CIL via conda, so setting `BUILD_CIL=OFF` in the docker build
- Added jupyterhub Dockerfile and documentation to build the jupyterhub image used in training on top of SIRF docker images and jupyter datascience-notebook image with GPU access.
- Adds Boost random for ISMRMRD 1.5.0 [#636](https://github.com/SyneRBI/SIRF-SuperBuild/issues/636)
- moved the VM repository to the `VirtualBox` subdirectory
- fix usage of `proj_EXTRA_CMAKE_ARGS` facility (it was broken for all projects except ITK) [#616](https://github.com/SyneRBI/SIRF-SuperBuild/issues/616)
- Boost: fix cases where the wrong version of boost could be found [#627](https://github.com/SyneRBI/SIRF-SuperBuild/issues/627)
- GTest: if USE_SYSTEM_GTest=OFF, attempt to force finding our version, otherwise, pass GTest_DIR or GTEST_ROOT on to dependent projects.
- add the CERN ROOT library (if USE_ROOT=ON, but defaults to OFF), which can be used by STIR to read GATE ROOT files.
- updated versions:
  - CMake: 3.16.2
  - ISMRMRD: 1.7.0 if siemens_to_ismrmrd is built, 1.4.2.1 otherwise
  - siemens_to_ismrmrd: [6d0ab3d3d0c8ade5c0526db1c6af9825008425ad](https://github.com/ismrmrd/siemens_to_ismrmrd/commit/6d0ab3d3d0c8ade5c0526db1c6af9825008425ad) > 1.2.2 with bug-fix for boost/foreach.hpp
  - ITK: 5.2.1 However, we now build a smaller set of modules,
     most (but not all) of IO, and Filtering. See SuperBuild/External_ITK.cmake)
  - NiftyReg: 99d584e2b8ea0bffe7e65e40c8dc818751782d92 ) (fixes gcc-9 OpenMP problems)
  - CIL: v21.4.0
  - GTest: 1.11.0
  - Boost: 1.72.0
  - JSON: 3.10.4
  - ACE: 6.5.9
  - parallelproj: v0.8

## v3.1.1

- added external project astra-python-wrapper to allow updates of ASTRA without conflicts [#605](https://github.com/SyneRBI/SIRF-SuperBuild/issues/605)
- fix docker/entrypoint for case where a user has a GID that already exists in the Docker image [#606](https://github.com/SyneRBI/SIRF-SuperBuild/issues/606)

## v3.1.0
- docker:
  - configure nbstripout in SIRF-Exercises for `sirf-service`
  - major change w.r.t. users and permissions. We now build as user `jovyan` (by default)
    and still switch to `sirfuser` for running the container. This avoids having to
    reset permissions of many files, and therefore speeds-up container start-up.
  - introduced `SIRF_SB_URL`, `SIRF_SB_TAG` and `NUM_PARALLEL_BUILDS`. They default to the
    values used before (i.e. resp. the main `SIRF-SuperBuild` repo, `master` and `2`).
  - add dependencies that are available only from conda-forge (for CIL)
  - improved documentation
- allow specifying `HDF5_URL` and `HDF5_TAG` like for other projects
- updated versions:
  - SIRF: 3.1.0
  - CIL: 21.2.0
  - CIL-ASTRA: 21.2.0
- disable built of NiftyPET by default as our current setup  requires Python2 for which we dropped support
- Continuous Integration testing:
    - Removed all Travis runs except those that run docker

## v3.0.0
- use BUILD_CIL=ON for all Docker builds
- Docker build moved to Python3 only.
- Environment files with name env_sirf.sh (and csh) are created. Symbolic links or copies with the previous name env_ccppetmr.sh (and csh) depending on the version of CMake available are made.
- Fix some issues with finding Python [#472](https://github.com/SyneRBI/SIRF-SuperBuild/issues/472)
- Handling dependent projects:
    - Sets `USE_ITK=ON` by default.
    - Disabled building of `Module_ITKReview` by default
    - Updates for CIL 20.11+ which has a different python module structure. CCPi-FrameworkPlugins has been also removed.
    - CIL repository has been transferred to the TomographicImaging organisation; reflect changes in CIL repositories
    - Patch Gadgetron include file hoNDFFT.h to remove spurious ".."
    - Add Gadgetron as a dependency of SIRF if `BUILD_Gadgetron` is `ON`.
    - Enabled HDF5 support for STIR by default (build C++ libraries for HDF5)
    - Add option `BUILD_TESTING_JSON` (default OFF)
- Updated versions:
   - JSON: 3.9.1
   - SWIG: 4.0.2
   - STIR: 4.1.1
   - SIRF: 3.0.0
   - CIL: 21.1.0
   - CCPi-Regularisation toolkit: 20.09
- Continuous Integration testing:
    - Add GitHub actions and removed most Travis runs
    - Switched Travis ctest from --verbose to --output-on-failure and added travis_wait of 20 minutes to keep it from timing-out if some tests take longer than 10.

## v2.2.0
- Updated to reflect change from CCPPETMR to CCPSyneRBI.
- Made ${proj}_SOURCE_DIR a cached variables such that the user can point to an existing directory.
- Added support for passing CMAKE args to projects from the SuperBuild call.
- Use macros to drastically simplify (and reduce size of) the External*.cmake files.
- Pass HDF5_ROOT through to projects if it's defined and USE_SYSTEM_HDF5=ON
- Added checking whether default SWIG executable exists.
- Corrected logic around building SIRF and Registration.
- Added JSON as external package.
- Added option to build ITK with static libraries.
- Added option to skip ITK path length checks.
- Added option to compile Armadillo without HDF5 support.
- Added options to disable STIR JSON support.
- Added option to disable CUDA.
- Added option to disable Gadgetron checkouts.
- Added option to disable Python or MATLAB support.
- Sorted out Nifty PET capitalisation.
- Unified OpenMP control.
- Updated versions:
   - STIR: rel_4.0.2
   - CIL:  20.04
   - SIRF: 2.2.0

## v2.1.0
- Switch NiftyReg remote from `rijobro` to `KCL-BMEIS` (following the acceptance of one of our PRs to their code).
- Azure:
    - Added NVIDIA GPU support
    - Now using Terraform HCL v0.12
- Added CCPi CIL support and various packages for that
- Added preliminary install option for NiftyPET
- Added CUDA and OpenMP support for some packages
- Improved documentation for docker
- Updated various versions
    - NiftyReg: 1.5.68
    - ISMRMRD: v1.4.1
    - STIR: stir_rel_4_00_alpha
    - SIRF: v2.1.0
    - PET RD Tools: v1.1.0
    - Armadillo: 9.800.2
- petmr-rd-tools -> pet-rd-tools fixes

## v2.0.0
- Added CMake Variable `Gadgetron_USE_MKL` to allow Gadgetron build with MKL if available
- Added build of NiftyReg and ACE (optional)
- Added tests for various packages, not just SIRF (CMake variables `BUILD_TESTING_*`)
- Updated various versions
    - ISMRMRD: v1.4.0
    - Gadgetron: [b6191ea](https://github.com/gadgetron/gadgetron/commit/b6191eaaa72ccca6c6a5fe4c0fa3319694f512ab)
    - Boost: 1.65.1 (linux) 1.68.0 (OSX)
    - STIR to version of 9 Apr 2019
    - SIRF v2.0.0. If NiftyReg is built (or provided), SIRF will be built with registration capabilities.
- docker images updates
  - Ubuntu: 18.04
  - `:service` images with `Jupyter` and `SIRF-Exercises`
- addition of Azure scripts
- require CMake: 3.10.0
- changed some CMake variable names:
   - `BUILD_GADGETRON` -> `BUILD_Gadgetron`
   - `BUILD_GADGETRON_NATIVE_MATLAB_SUPPORT` -> `Gadgetron_BUILD_MATLAB_SUPPORT`
   - `BUILD_STIR_WITH_OPENMP` -> `STIR_ENABLE_OPENMP`
   - `BUILD_STIR_EXECUTABLES` -> `STIR_BUILD_EXECUTABLES`
   - `BUILD_STIR_SWIG_PYTHON` -> `STIR_BUILD_SWIG_PYTHON`
- petmr-rd-tools -> pet-rd-tools

## v1.1.0

- Added PYTHON_DEST_DIR variable, which allows the user to select the install destination of the SIRF python modules. PYTHON_DEST_DIR is a cached variable which can be updated on the GUI. If PYTHON_DEST_DIR is not set, we will install in ${CMAKE_INSTALL_PREFIX}/python. Likewise for MATLAB_DEST_DIR.
- Export `GADGETRON_HOME` environment variable (necessary for recent versions of Gadgetron)
- Updates to Docker builds
- On OSX, use the system boost by default to avoid run-time problems with boost dynamic libraries
- Build STIR with OPENMP

## v1.0.0

 - optionally build siemens_to_ismrmrd
 - optionally build petmr_rd_tools
 - major [restructuring](https://github.com/CCPPETMR/SIRF-SuperBuild/issues/16#issuecomment-360772097) of SuperBuild build directory
 - User can specify the location of the sources via the variable `SOURCES_ROOT_DIR`
 - Updated dependency versions (STIR)
 - Defaults to `USE_SYSTEM_BOOST=ON` on Windows and MacOSX [#63](https://github.com/CCPPETMR/SIRF-SuperBuild/issues/63), see [here](https://github.com/CCPPETMR/SIRF/wiki/SIRF-SuperBuild-on-MacOS#2-boost-)

## New in Release 0.9.1

- build specific versions of dependencies (ISMRMRD, Gadgetron, STIR, SIRF)
- run tests via CTest
