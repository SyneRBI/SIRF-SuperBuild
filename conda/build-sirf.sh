#!/usr/bin/env bash
# SIRF 3.10.1 — C++ + Python. CPU by default; CUDA (cGadgetron) when
# GADGETRON_USE_CUDA=ON. Gadgetron / ISMRMRD / pet-rd-tools come from the sibling
# conda outputs; STIR from conda-forge (CPU); NIFTYREG from conda-forge.
set -euxo pipefail

# NiftyReg 1.5.69.6 (the only conda-forge build) ships a broken inline getter in
# _reg_aladin.h: reg_aladin<T>::GetInputTransform() returns this->InputTransform,
# but no such member exists (only `char *InputTransformName`). Being an inline
# template method, it only fails when SIRF instantiates reg_aladin (in
# NiftyAladinSym.cpp). SIRF never calls GetInputTransform(), so neutralise it.
# (The SuperBuild instead builds NiftyReg from commit a328efb, which lacks this bug.)
sed -i 's/return this->InputTransform;/return nullptr;/' "$PREFIX/include/_reg_aladin.h"

# fix static STIR on glibc>=2.35: STIR (gcc, -ffast-math) references glibc's
# errno-free __*_finite math symbols, unresolvable in a static link. Build a
# thin shim as a static archive and append it to the END of the _pystir link
# line (after the STIR .a files that reference them), so the refs resolve.
# (CMAKE_SHARED_LINKER_FLAGS would place the .a before the STIR .a — wrong
# order — and a shared shim leaves the archive refs unresolved, hence this
# build.ninja post-pass.)
"$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-gcc" -c -O2 "$RECIPE_DIR/stir-math-shim.c" \
  -o "$BUILD_PREFIX/stir-math-shim.o"
"$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-ar" rcs \
  "$BUILD_PREFIX/libstir_math_shim.a" "$BUILD_PREFIX/stir-math-shim.o"

if [ "${GADGETRON_USE_CUDA:-OFF}" = "ON" ]; then
  export CUDA_TOOLKIT_ROOT_DIR="${PREFIX}"
  export CUDA_ROOT="${PREFIX}"
fi

# STIR 6.3.0 (conda-forge) ships STIRTargets.cmake with absolute paths from the
# feedstock build env (h_env prefix and _build_env sysroot libs) in
# INTERFACE_LINK_LIBRARIES/INCLUDE_DIRECTORIES; linking SIRF targets against the
# STIR targets puts the nonexistent paths on the link line. Rewrite the h_env
# prefix to $PREFIX and drop the sysroot entries (pthread/dl/m are no-ops on
# glibc >= 2.34). No-op for STIR 6.4.0 (clean exports).
python - <<'EOF'
import glob, os, re
prefix = os.environ['PREFIX']
for p in glob.glob(os.path.join(prefix, 'lib', 'cmake', 'STIR-6.*', '*.cmake')):
    s = open(p).read()
    if 'feedstock_root' not in s:
        continue
    s = re.sub(r';/home/conda/feedstock_root/build_artifacts/[a-z0-9_]+/_build_env/[^;\s"]*', '', s)
    s = re.sub(r'/home/conda/feedstock_root/build_artifacts/[a-z0-9_]+/[a-z0-9_]+(?=/)', prefix, s)
    open(p, 'w').write(s)
EOF

cmake -G Ninja $SRC_DIR \
  -B $BUILD_PREFIX/build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DRUN_ISMRMRD_SHEPP_LOGAN:BOOL=OFF \
  -DDISABLE_Matlab:BOOL=ON \
  -DDISABLE_PYTHON:BOOL=OFF \
  -DPython_EXECUTABLE=$PREFIX/bin/python \
  -DPYTHON_DEST_DIR=$SP_DIR \
  -DDISABLE_Registration:BOOL=OFF \
  -DDISABLE_Gadgetron:BOOL=OFF \
  -DGadgetron_USE_CUDA:BOOL=${GADGETRON_USE_CUDA:-OFF}

# append the shim .a to every link line that pulls in STIR's static build block
# (libstir_buildblock.a in 6.4.0, libbuildblock.a in 6.3.0) — these are the
# targets whose STIR .a objects reference the glibc __*_finite symbols — so the
# refs resolve. Also: with STIR 6.3.0 (bare-name STIR_LIBRARIES), the STIR
# archives' mutual references (e.g. final libbuildblock.a -> libIO.a) and their
# H5::H5File refs can't be resolved in a single left-to-right pass; wrap
# _pyreg's link line in --start-group/--end-group (archive re-scanning) and put
# the hdf5 libs + shim after the group (no-op for 6.4.0, whose CMake target
# interface already orders everything correctly). Then verify the shim landed.
awk -v shim="$BUILD_PREFIX/libstir_math_shim.a" -v hdf5="$PREFIX/lib/libhdf5_cpp.so $PREFIX/lib/libhdf5.so" '
  /^build / { inpyreg = ($0 ~ /_pyreg\.so/) }
  /^  LINK_LIBRARIES =/ {
    if (($0 ~ /libstir_buildblock/ || $0 ~ /libbuildblock/) && $0 !~ /stir_math_shim/) sub(/$/, " " shim)
    if (inpyreg) {
      sub(/^  LINK_LIBRARIES = /, "  LINK_LIBRARIES = -Wl,--start-group ")
      sub(/$/, " -Wl,--end-group " hdf5 " " shim)
    }
  }
  { print }
' "$BUILD_PREFIX/build/build.ninja" > "$BUILD_PREFIX/build/build.ninja.new" \
  && mv "$BUILD_PREFIX/build/build.ninja.new" "$BUILD_PREFIX/build/build.ninja"
grep -q "libstir_math_shim.a" "$BUILD_PREFIX/build/build.ninja" \
  || { echo "ERROR: shim not appended to STIR link lines"; exit 1; }

cmake --build $BUILD_PREFIX/build --config Release
cmake --install $BUILD_PREFIX/build --config Release

# SIRF-Contribs (pure-Python, extends the sirf namespace with sirf.contrib).
# pip runs without build isolation (rattler-build sets PIP_NO_BUILD_ISOLATION,
# which pip >=26 interprets as "isolation off"), so the setuptools backend is
# imported from the host env — hence the explicit setuptools host dep.
$PREFIX/bin/python -m pip install "git+https://github.com/SyneRBI/SIRF-Contribs.git@v3.10.0"

# SIRF runtime env vars on activation (examples_data_path, Gadgetron relay)
mkdir -p "$PREFIX/etc/conda/activate.d"
cp "$RECIPE_DIR/activate-sirf.sh" "$PREFIX/etc/conda/activate.d/sirf-activate.sh"
