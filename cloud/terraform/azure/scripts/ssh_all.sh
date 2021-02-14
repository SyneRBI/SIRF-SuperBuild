#!/bin/sh

#  Copyright (C) 2019 University College London
# This is software developed for the Collaborative Computational
# Project in Positron Emission Tomography and Magnetic Resonance imaging
# (http://www.ccpsynerbi.ac.uk/).

#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0.txt
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#=========================================================================
#      
# Author Kris Thielemans

print_usage_and_exit()
{
  echo "Usage:"
  echo "   `basename $prog` host_filename password command"
  echo "Runs command on every host listed in the file"
  echo ""
  echo "Examples:"
  echo "   `basename $prog` list_of_hosts.txt virtual%1 /home/sirfuser/devel/install/bin/update_VM.sh"
  exit 1
}

prog=$0


if [ $# -ne 3 ]
then
  print_usage_and_exit
fi

listofhosts=$1
password=$2
command=$3
while read -r h; do
    echo "============== host $h ========================"
    ssh-keygen -R $h
    sshpass -p "$password" ssh -n -o "StrictHostKeyChecking no" $h $command
    echo Exit status $?
    echo "============== done host $h ==================="
done < $listofhosts

