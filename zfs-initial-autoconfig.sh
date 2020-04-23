#!/bin/bash

## Configuring main ZFS pool with right / recommended settings, pool in RAIDZ1, 1 SLOG, 1 L2ARC and 3 disks
## THIS ONLY WORKS FOR THE STOCK KERNEL, AS IT DOESN'T CONFIGURE ZFS DKMS 

## USER DEFINED VARIABLES
# Fill these out with the correct disk by-id or UUIDs (FULL PATH REQUIRED /dev/by-id or /dev/by-uuid)
# Note: DISK 1 will determine your ASHIFT size
DISK1=
DISK2=
DISK3=
SLOG1=
SLOG2=
L2ARC1=
POOLNAME=
## END USER DEFINED VARIABLES

read -p 'Have you filled out the User Defined Variables? [y/n]: ' uservarprompt
read -p "WARNING! ALL DATA ON TARGET DISKS WILL BE WIPED, ARE YOU SURE YOU WANT TO PROCEED? [y/n]: " uservarprompt

if [[ $uservarprompt = 'y' ]]; then
    ## Load ZFS module on startup
    sudo touch /etc/modules-load.d/zfs.conf
    sudo echo zfs > /etc/modules-load.d/zfs.conf
    ## Load ZFS module
    sudo modprobe zfs
    ## Stuff
    sudo systemctl enable --now zfs-import-cache
    sudo systemctl enable --now zfs-import.target
    sudo systemctl enable --now zfs-mount
    sudo systemctl enable --now zfs.target

    ## Create zpool and determining ashift value
    echo "Creating pool..."
    # Determining ashift value

    # Creating pools based on ASHIFT value

        sudo zpool create -o ashift=12 -f -m /"$POOLNAME" "$POOLNAME" raidz "$DISK1" "$DISK2" "$DISK3"

    # Adding log devices
    sudo fdisk -l $SLOG1 | grep "Sector size" > /tmp/blocksize-log
    sudo echo $(cut -c 43-69420 /tmp/blocksize-log) > /tmp/blocksize-log
    if grep -q "8192 bytes" "/tmp/blocksize-log"; then 
       ASHIFT=13
    else
       ASHIFT=12
    fi

        sudo zpool add -o ashift=$ASHIFT -f  "$POOLNAME" log mirror "$SLOG1" "$SLOG2"
    

    # Adding Cache devices
    sudo fdisk -l $L2ARC1 | grep "Sector size" > /tmp/blocksize-cache
    sudo echo $(cut -c 43-69420 /tmp/blocksize-cache) > /tmp/blocksize-cache
    if grep -q "8192 bytes" "/tmp/blocksize-cache"; then 
       ASHIFT=13
    else
       ASHIFT=12
    fi


    sudo zpool add -o ashift=$ASHIFT -f "$POOLNAME" cache "$L2ARC1"


    echo "Ok! Listing Status"
    # Zpool Status
    zpool status -v 
    wait 3

    echo "Configuring pool..."
    # Setting important ZFS flags
    # sudo zfs set sync=always "$POOLNAME" 
    sudo zfs set compression=lz4 "$POOLNAME"
    sudo zfs set atime=on "$POOLNAME"
    sudo zfs set relatime=on "$POOLNAME"

    echo "Start pool scrub in background..."
    sudo zpool scrub "$POOLNAME"
    echo "Scrub pool on timer"
    sudo cp ./etc/zfs-scrub@.service /etc/systemd/system/zfs-scrub@.service
    sudo cp ./etc/zfs-scrub@.timer /etc/systemd/system/zfs-scrub@.timer
    sudo systemctl enable --now zfs-scrub@"$POOLNAME".timer
    echo "Creating Datasets"
    sudo zfs create "$POOLNAME"/userdata
    sudo zfs create "$POOLNAME"/appdata
    echo "Done!"















else 
    echo "Exiting..."
    exit
fi