#!/usr/bin/env bash
# SIRF 3.10.1 — C++ + Python (Linux + macOS). CPU by default; CUDA
# (cGadgetron) on Linux when GADGETRON_USE_CUDA=ON.
# Windows: see build-sirf.ps1.
set -euxo pipefail

# NiftyReg 1.5.69.6 (the only conda-forge build) ships a broken inline getter in
# _reg_aladin.h: reg_aladin<T>::GetInputTransform() returns this->InputTransform,
# but no such member exists (only `char *InputTransformName`). Being an inline
# template method, it only fails when SIRF instantiates reg_aladin (in
# NiftyAladinSym.cpp). SIRF never calls GetInputTransform(), so neutralise it.
# (The SuperBuild instead builds NiftyReg from commit a328efb, which lacks this bug.)
python - "$PREFIX/include/_reg_aladin.h" <<'EOF'
import os, sys
p = sys.argv[1]
s = open(p).read()
if "return this->InputTransform;" in s:
    # os.replace puts the patched header on a NEW inode: writing in place would
    # also modify the rattler package cache (files are hardlinked out of it),
    # poisoning later builds whose cache restore reuses the extracted dir.
    t = p + "~"
    with open(t, "w") as f:
        f.write(s.replace("return this->InputTransform;", "return nullptr;"))
    os.replace(t, p)
elif "GetInputTransform" in s:
    print(f"niftyreg {p}: buggy getter absent (already patched or fixed upstream), skipping")
else:
    sys.exit(f"niftyreg {p}: not a _reg_aladin.h (no GetInputTransform); aborting")
EOF

if [ "$(uname -s)" = "Linux" ]; then
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
fi

if [ "${GADGETRON_USE_CUDA:-OFF}" = "ON" ]; then
  export CUDA_TOOLKIT_ROOT_DIR="${PREFIX}"
  export CUDA_ROOT="${PREFIX}"
  # FindCUDA fix for conda cuda>=13.1
  export CUDA_INC_PATH="${PREFIX}/targets/x86_64-linux"
  export CUDA_LIB_PATH="${PREFIX}/targets/x86_64-linux"
fi

# On Apple (Mach-O) a static archive merged into an executable/Python bundle
# cannot bind the gadgetron toolboxes' weak_odr NFFT vtables/member functions,
# so disable the CPU radial-gridding toolboxes (NonCartesianEncoding) on Apple.
# The Gadgetron client (server-based reconstruction) and the sirf.Gadgetron
# Python module still build and work; the rest of SIRF is unaffected.
EXTRA_CMAKE_ARGS=""
if [ "$(uname -s)" = "Darwin" ]; then
  EXTRA_CMAKE_ARGS="$EXTRA_CMAKE_ARGS -DDISABLE_Gadgetron_TOOLBOXES:BOOL=ON"
fi

cmake -G Ninja $SRC_DIR \
  -B $BUILD_PREFIX/build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DRUN_ISMRMRD_SHEPP_LOGAN:BOOL=OFF \
  -DDOWNLOAD_ZENODO_TEST_DATA:BOOL=ON \
  -DDISABLE_Matlab:BOOL=ON \
  -DDISABLE_PYTHON:BOOL=OFF \
  -DPython_EXECUTABLE=$PREFIX/bin/python \
  -DPYTHON_DEST_DIR=$SP_DIR \
  -DDISABLE_Registration:BOOL=OFF \
  -DDISABLE_Gadgetron:BOOL=OFF \
  -DGadgetron_USE_CUDA:BOOL=${GADGETRON_USE_CUDA:-OFF} \
  $EXTRA_CMAKE_ARGS

if [ "$(uname -s)" = "Linux" ]; then
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
      if (($0 ~ /buildblock/) && $0 !~ /stir_math_shim/) sub(/$/, " " shim)  # bare STIR names (6.3.0), lib*/libstir_* (6.4.0)
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
fi

if [ "$(uname -s)" = "Darwin" ]; then
  # The Python .so's merge the static SIRF libs. On macOS ld64 only pulls
  # referenced objects from a static archive into the .so, so a global (e.g. a
  # lock) whose constructor lives in an otherwise-unreferenced object never
  # runs -> the global stays NULL -> segfault on import (PyThread_acquire_lock(
  # NULL) at address 0x38). Force-load every static lib in the .so link lines so
  # all objects (and constructors) are included. Conda deps are .dylib on macOS,
  # so only the SIRF .a files match.
  #
  # Also: on macOS a Python extension that links libpython directly is imported
  # into an interpreter that already has libpython loaded, so the duplicated
  # libpython state corrupts process-wide globals (cf. conda-forge
  # boost-feedstock#266) -> a null lock / converter at PyInit time -> segfault.
  # Link with -undefined dynamic_lookup (interpreter supplies the Python symbols
  # at load time) and drop the -lpython link, as conda-forge does for osx
  # Python extensions.
  awk '
    /^build / { isso = ($0 ~ /\.so/) }
    /^  LINK_LIBRARIES =/ {
      if (isso) {
        out = ""
        n = split($0, parts, " ")
        for (i = 1; i <= n; i++) {
          if (parts[i] ~ /^-lpython[0-9.]*$/) continue
          if (parts[i] ~ /\/libpython[0-9a-z.]*\.dylib$/) continue
          if (parts[i] ~ /\/lib[A-Za-z0-9_]+\.a$/) { out = out " -Wl,-force_load," parts[i]; continue }
          out = out " " parts[i]
        }
        # -lpng: a force-loaded static lib (an ITK PNG IO object) references
        # png_create_info_struct; with -undefined dynamic_lookup that ref is left
        # undefined and only resolves at load if libpng is a direct dep of the .so.
        out = out " -Wl,-undefined -Wl,dynamic_lookup -lpng"
        $0 = out
      }
    }
    { print }
  ' "$BUILD_PREFIX/build/build.ninja" > "$BUILD_PREFIX/build/build.ninja.new" \
    && mv "$BUILD_PREFIX/build/build.ninja.new" "$BUILD_PREFIX/build/build.ninja"
  grep -q "dynamic_lookup" "$BUILD_PREFIX/build/build.ninja" \
    || echo "WARNING: dynamic_lookup not added to .so link lines (check build.ninja)"
fi

cmake --build $BUILD_PREFIX/build --config Release
cmake --install $BUILD_PREFIX/build --config Release

# SIRF-Contribs (pure-Python, sirf.contrib) is now built as a separate output
# (the sirf-contrib output in recipe.yaml); not installed here.

# SIRF runtime env vars on activation (examples_data_path, Gadgetron relay)
mkdir -p "$PREFIX/etc/conda/activate.d" "$PREFIX/etc/conda/deactivate.d"
for ext in sh csh fish bat ps1; do
  cp "$RECIPE_DIR/activate-sirf.$ext" "$PREFIX/etc/conda/activate.d/sirf-activate.$ext"
  cp "$RECIPE_DIR/deactivate-sirf.$ext" "$PREFIX/etc/conda/deactivate.d/sirf-deactivate.$ext"
done

# --- test suite (C++ tests; the python tests run in the rattler test phase) ---
# ctest needs the build tree, so it runs here. The MR/Gadgetron tests talk to a
# live gadgetron server (relay 127.0.0.1:9002) and, for CUDA builds, to a GPU;
# skip them for CUDA builds without a GPU (standard CI runners).
SERVER_TESTS=ON
if [ "${GADGETRON_USE_CUDA:-OFF}" = "ON" ] && ! nvidia-smi -L >/dev/null 2>&1; then
  SERVER_TESTS=OFF
fi
# SYN_TEST_CPLUSPLUS runs a Gadgetron resampler sub-test that needs the relay, so
# exclude it too when the relay is off (its STIR/Nifti sibling stays in the set).
EXCLUDES='_PYTHON|_DEMOS'
[ "$SERVER_TESTS" = OFF ] && EXCLUDES+='|MR_|GADGETRON|SYN_TEST_CPLUSPLUS'
CTEST_ARGS=(--test-dir "$BUILD_PREFIX/build" --verbose --output-on-failure -E "$EXCLUDES")

# relay config lookup (port/bind); set BEFORE starting the relay, cf. activate-sirf.sh
export GADGETRON_HOME="$PREFIX"
GADGETRON_PID=""
if [ "$SERVER_TESTS" = ON ]; then
  "$PREFIX/bin/gadgetron" > "$BUILD_PREFIX/gadgetron.log" 2>&1 &
  GADGETRON_PID=$!
  # wait for the relay port (up to 60s)
  for i in $(seq 1 60); do
    (exec 3<>/dev/tcp/127.0.0.1/9002) 2>/dev/null && { exec 3>&-; break; }
    sleep 1
  done
fi
set +e
ctest "${CTEST_ARGS[@]}"
test_fail=$?
set -e
[ -n "$GADGETRON_PID" ] && kill "$GADGETRON_PID" 2>/dev/null || true
if [ "$test_fail" -ne 0 ]; then
  echo "----------- Last 70 lines of gadgetron.log"
  tail -n 70 "$BUILD_PREFIX/gadgetron.log" 2>/dev/null || true
  exit "$test_fail"
fi

# The example data ships in the separate (optional) sirf-data package; strip the copy
# the CMake installed so it isn't duplicated into the sirf package.
rm -rf "$PREFIX"/share/SIRF-*/data
