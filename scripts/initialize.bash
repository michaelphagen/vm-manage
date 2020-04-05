#!/bin/bash
# Script for adjusting a generic development environment when initializing a new VM
# Should be placed in the /bin/ directory on a template machine with a user account and 
# ssh login via root enabled using password "password"
  
# Confirms that the script is being run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi
case $# in        
    0)
    echo "Entering Interactive Mode"
    # Asks the User for the relevant information for setting up the new instance
    read -p 'New Hostname: ' hostvar
    read -p 'New Username: ' uservar
    read -sp 'New Password: ' passvar
    echo
    read -sp 'Confirm New Password: ' passconfirm
    echo
    ;;
    
    3)
    echo "Values entered via command line, proceeding"
    hostvar=$1
    uservar=$2
    passvar=$3
    passconfirm=$3
    ;;

    *)
    echo "Incorrect number or type of values passed, Entering Interactive Mode"
    # Asks the User for the relevant information for setting up the new instance
    read -p 'New Hostname: ' hostvar
    read -p 'New Username: ' uservar
    read -sp 'New Password: ' passvar
    echo
    read -sp 'Confirm New Password: ' passconfirm
    echo
    ;;
esac


# If passwords match, proceed with modifying the installation
if [[ "$passvar" == "$passconfirm" ]]; then
    echo "Passwords Match, changing values now"
    # Changes the username, password, and home directory
    echo "Changing user password"
    echo "user:$passvar" | chpasswd
    echo "Changing username"
    usermod -l $uservar user
    usermod -d /home/$uservar -m $uservar
    # Changes the computer's hostname
    echo "Changing hostname"
    hostnamectl set-hostname $hostvar
    # Disables root login, both via ssh and locally by removing the root password
    echo "Disabling root login"
    sed -i 's/PermitRootLogin/#PermitRootLogin/' /etc/ssh/sshd_config
    passwd -l root
    echo "Rebooting now!"
    sleep 5
    reboot now

else
    echo "Passwords do not match, please run command again"
    exit
fi