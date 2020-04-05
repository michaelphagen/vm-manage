#!/bin/bash
# Script for starting a vm headless and ssh-ing into it
source /Library/Scripts/vm-manage/settings.ini
vmrun start "$VIRTUALMACHINEDIRECTORY"/$1.vmwarevm/$1.vmx nogui >/dev/null
MAC=$(grep "ethernet0.address = " "$VIRTUALMACHINEDIRECTORY"/$1.vmwarevm/$1.vmx | sed 's/ethernet0.address = //' | sed 's/"//g')
if [[ "$MAC" == "" ]]; then
    MAC=$(grep "ethernet0.generatedAddress = " "$VIRTUALMACHINEDIRECTORY"/$1.vmwarevm/$1.vmx | sed 's/ethernet0.generatedAddress = //' | sed 's/"//g')
fi
PADMAC=$(echo "$MAC" | sed "s/:0/:/g")
echo "Looking for ip address matching $PADMAC"
while [[ "$ip" == "" ]]; do
    ip=$(arp -a | grep -w -i "${PADMAC:1}" | awk '{print $2}'|sed 's/[)(]//g')
done
echo "IP Address found! Connecting to $ip"
((count = 100))
    while [[ $count -ne 0 ]] ; do
        echo "Waiting for connection"
        sleep 1
        ping -c 1 $ip >/dev/null                # Try once.
        rc=$?
        if [[ $rc -eq 0 ]] ; then
            ((count = 1))                      # If okay, flag to exit loop.
        fi
        ((count = count - 1))                  # So we don't go forever.
    done
if [ "$2" != "" ]; then
    ssh $2@$ip
else
    ssh $ip
fi