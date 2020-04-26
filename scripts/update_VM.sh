#!/bin/sh

echo "Updating..."
if [ -d $userHOME/devel/CCPPETMR_VM ]; then
  if [ ! -h $userHOME/devel/SyneRBI_VM ]; then
    ln -s $userHOME/devel/CCPPETMR_VM $userHOME/devel/SyneRBI_VM
  fi
fi
cd ~/devel/SyneRBI_VM
git pull
cd scripts

./UPDATE.sh $*

echo "All done"
