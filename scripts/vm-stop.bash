#!/bin/bash
# Script for stoping a headless vm
source /Library/Scripts/vm-manage/settings.ini
if [ "$1" != "" ]; then
vmrun stop "$VIRTUALMACHINEDIRECTORY"/$1.vmwarevm/$1.vmx
else
    vmrun list
    echo "Please specify VM"
    exit
fi