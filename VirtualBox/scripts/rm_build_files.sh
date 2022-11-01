#! /bin/sh
# script that deletes the build files to reduce VM size
loc="$SIRF_SRC_PATH"/buildVM/builds
echo "Removing all files in $loc in 5s."
echo 'Press Ctrl-C NOW to abort if you do not want that.'
echo ''
echo 'Note that after removing these files, you can still use upgrade_VM.sh'
echo 'as well as build (via "make") as this keeps the CMake configuration.'
sleep 5
rm -rf "$loc"

echo 'Clearing ccache files.'
echo '(This is harmless, just means larger rebuild times the first time).'
ccache --clear

