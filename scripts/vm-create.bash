#!/bin/bash
# Script for cloning a template VM to create new machines from the command line

# Imports the settings file
source /Library/Scripts/vm-manage/settings.ini
# Generates a random mac address in the range registered for VMware
MAC=$(printf "00:50:56:%02X:%02X:%02X\n" $[RANDOM%256] $[RANDOM%256] $[RANDOM%256])
case $# in        
        
    1)
    read -p 'Only 1 Argument was passed. Do you want to use Quick Clone Mode? (y/n)' answer
    if [[ "$answer" != "y" ]]; then
        echo "Aborting"
        exit 1
    else
        hostvar=$1
    fi
    ;;
    
    3)
    echo "Values entered via command line, proceeding"
    hostvar=$1
    uservar=$2
    passvar=$3
    passconfirm=$3
    ;;
    
    *)
    if [[ "$1" == "" ]]; then
        echo "Entering Interactive Mode"
    else
        echo "Bad Arguments passed, Entering Interactive Mode"
    fi
    # Asks the User for the relevant information for setting up the new instance
    read -p 'New VM Name: ' hostvar
    read -p 'Username for new VM: ' uservar
    read -sp 'Password for new VM: ' passvar
    echo
    read -sp 'Confirm New Password: ' passconfirm
    echo
    if [[ "$passvar" != "$passconfirm" ]]; then
        echo "Passwords do not match, aborting"
        exit 1
    else
        echo "Specified values are valid, proceeding"
    fi
    ;;
esac

echo "Cloning Template VM" 
vmrun clone "$TEMPLATEVM" "$VIRTUALMACHINEDIRECTORY"/$hostvar.vmwarevm/$hostvar.vmx full
sed -i "" "s/00:00:00:00:00:00/$MAC/" "$VIRTUALMACHINEDIRECTORY"/$hostvar.vmwarevm/$hostvar.vmx
echo "Starting new VM" 
vmrun start "$VIRTUALMACHINEDIRECTORY"/$hostvar.vmwarevm/$hostvar.vmx nogui >/dev/null
echo "Getting IP Address of new VM"
PADMAC=$(echo "$MAC" | sed "s/:0/:/g")
while [[ "$ip" == "" ]]; do
    ip=$(arp -a | grep -w -i "${PADMAC:1}" | awk '{print $2}'|sed 's/[)(]//g')
done
echo "IP Address is $ip. Connecting now"
((count = 100))
while [[ $count -ne 0 ]] ; do
    sleep 1
    ping -c 1 "$ip" >/dev/null                  # Try once.
    rc=$?
    if [[ $rc -eq 0 ]] ; then
        ((count = 1))                      # If okay, flag to exit loop.
    fi
    ((count = count - 1))                  # So we don't go forever.
done



# If not in quick clone mode, send arguments to run initialize script on new VM
if [[ "$uservar" != "" ]]; then
    echo "Please enter the root password of your template VM when prompted"
    echo "connecting to $ip at mac address $MAC"
    ssh root@"$ip" /bin/start "$hostvar" "$uservar" "$passvar"
    ((count = 100))
    while [[ $count -ne 0 ]] ; do
        sleep 1
        ping -c 1 $ip >/dev/null                # Try once.
        rc=$?
        if [[ $rc -eq 0 ]] ; then
            ((count = 1))                      # If okay, flag to exit loop.
        fi
        ((count = count - 1))                  # So we don't go forever.
    done
    echo "Clone completed. Please enter your new credentials to login via ssh."
    ssh "$uservar"@"$ip"
# If in quick clone mode, ssh into the new VM as root
else
    echo "Quick clone completed, logging you in as root"
    ssh root@"$ip"
fi