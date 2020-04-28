#!/bin/sh

echo "Updating..."
if [ -d $userHOME/devel/CCPPETMR_VM ]; then
  if [ ! -h $userHOME/devel/SyneRBI_VM ]; then
    ln -s $userHOME/devel/CCPPETMR_VM $userHOME/devel/SyneRBI_VM
    cd $userHOME/devel/CCPPETMR_VM
    git remote set-url origin https://github.com/SyneRBI/SyneRBI_VM.git
  fi
fi
cd ~/devel/SyneRBI_VM
git pull
cd scripts

./UPDATE.sh $*

echo "All done"
