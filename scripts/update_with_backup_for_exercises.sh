#! /bin/sh
# updating SIRF-Exercises etc can fail when people are running things.
# To avoid this, this script moves the exercises to a backup folder
cd $SIRF_SRC_PATH # i.e. ~/devel
timestamp=` date -Iseconds`
backup_dir=$SIRF_SRC_PATH/backup_${timestamp}
mkdir ${backup_dir}
rm -rf $SIRF_PATH/data/examples/PET/working_folder
for ex in SIRF-Exercises STIR-exercises CIL-Demos; do
  if [ -d $ex ]; then
    mv $ex ${backup_dir}
  fi
done
update_VM.sh
