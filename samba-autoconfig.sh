#!/bin/bash

## Automatic configuration for Samba within the ZFS Pool

## USER DEFINED VARIABLES
POOLNAME=
## END USER DEFINED VARIABLES

read -p 'Have you filled out the User Defined Variables? [y/n]: ' uservarprompt
if [[ $uservarprompt = 'y' ]] then
    echo "Copying new smb configuration"

    # Backup old config
    sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak1

    # Installing new config

    sudo cp ./etc/smb.conf /etc/samba/smb.conf

    echo "Configuring ZFS"
    # All user r/w access on pool
    sudo chmod -R 777 /$POOLNAME

    sudo zfs set sharesmb=on "$POOLNAME"

    echo "Done!"

else 
    echo "Exiting..."
    exit
fi