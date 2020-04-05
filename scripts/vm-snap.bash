#!/bin/bash
source /Library/Scripts/vm-manage/settings.ini
if [ "$1" != "" -a  "$2" != "" ]; then
    case $1 in
        list)
        command="listSnapshots"
        ;;

        save)
        command="snapshot"
        if [[ "$#" == "3" ]]; then 
            snapame=$3
        else
            read -p "What should the new snapshot be named: " snapname
        fi
        echo "Creating new snapshot $snapname on VM $2"
        ;;

        load)
        command="reverToSnapshot"
        vmrun listSnapshots "$VIRTUALMACHINEDIRECTORY"/$2.vmwarevm/$2.vmx
        if [[ "$#" == "3" ]]; then 
            snapame=$3
        else
            read -p 'Which snapshot would you like to load: ' snapname
        fi
        echo "Loading snapshot $snapname on VM $2"
        ;;

        delete)
        command="deleteSnapshot"
        vmrun listSnapshots "$VIRTUALMACHINEDIRECTORY"/$2.vmwarevm/$2.vmx
        if [[ "$#" == "3" ]]; then 
            snapame=$3
        else
            read -p 'Which snapshot would you like to delete: ' snapname
        fi
        read -p "ARE YOU SURE THAT YOU WANT TO DELETE SNAPSHOT $snapname? (type YES to confirm): " answer
            if [[ "$answer" == "YES" ]]; then
                    echo "Deleting $snapname on VM $2"
            else
                    echo "Deletion aborted"
                    exit 1
            fi
        ;;

        *)
        echo "Command not found"
        exit 1
        ;;
    esac
    vmrun $command "$VIRTUALMACHINEDIRECTORY"/$2.vmwarevm/$2.vmx "$snapname"
else
    echo "Please specify VM followed by command"
    exit
fi