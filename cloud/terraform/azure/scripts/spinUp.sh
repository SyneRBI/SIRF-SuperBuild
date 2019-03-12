#!/bin/bash

CSVFILE=${1}
PREFIX=${2}
IMGPREFIX=${3}
RESGROUP=${4}

while IFS=, read -r ID LOC MACHSIZE 
do
    MACHSIZE=`echo $MACHSIZE | tr -d '\r'`
    MACHNAME="${PREFIX}${ID}"
    IMG="${IMGPREFIX}${LOC}"
    ARGS="az vm create -g $RESGROUP -n $MACHNAME --location ${LOC} --image ${IMG} --admin-username sirfuser --generate-ssh-keys --public-ip-address-dns-name $MACHNAME --size $MACHSIZE"
    echo $ARGS
    #$ARGS
    echo

    VMID=`az vm list -g ${RESGROUP} --query "[].id"  -o tsv | grep ${MACHNAME}`
    ARGS="az vm open-port --ids ${VMID} --port 9999"
    echo $ARGS
    $ARGS
    ARGS="az vm open-port --ids ${VMID} --port 3389 --priority 1001"
    echo $ARGS
    $ARGS
    echo

done < ${CSVFILE}


exit