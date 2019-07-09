#!/bin/bash

# Example usage: ./spinUp.sh <OPCODE> <CSVFILE> <VMPREFIX> <IMAGEPREFIX> <RESGROUP>
#
# where:
#   OPCODE is 'create' or 'open'. 'create' will build the machines; 'open' opens the required TCP ports.
#   CSVFILE is a CSV file that contains the numerical ID, geographical region and machine size.
#   VMPREFIX is the value to prefix all virtual machine with e.g. sirf.
#   IMGPREFIX is the name given to the Azure machine image e.g. PSMR2019-.
#   RESGROUP is the resource group which the image (and machine) reside in. e.g. psmrGroup

OPCODE=${1}
CSVFILE=${2}
PREFIX=${3}
IMGPREFIX=${4}
RESGROUP=${5}

echo $OPCODE

if [ $OPCODE == "create" ]
then
    while IFS=, read -r ID LOC MACHSIZE 
    do
        MACHSIZE=`echo $MACHSIZE | tr -d '\r'`
        MACHNAME="${PREFIX}${ID}"
        IMG="${IMGPREFIX}${LOC}"
        ARGS="az vm create -g $RESGROUP -n $MACHNAME --location ${LOC} --image ${IMG} --admin-username sirfuser --generate-ssh-keys --public-ip-address-dns-name $MACHNAME --size $MACHSIZE --no-wait"
        echo $ARGS
        $ARGS
    done < ${CSVFILE}
fi


if [ $OPCODE == "open" ]
then
    while IFS=, read -r ID LOC MACHSIZE 
    do
        MACHNAME="${PREFIX}${ID}"
        VMID=`az vm list -g ${RESGROUP} --query "[].id"  -o tsv | grep ${MACHNAME}`
        ARGS="az vm open-port --ids ${VMID} --port 9999"
        echo $ARGS
        $ARGS
        ARGS="az vm open-port --ids ${VMID} --port 3389 --priority 1001"
        echo $ARGS
        $ARGS
    done < ${CSVFILE}
fi
