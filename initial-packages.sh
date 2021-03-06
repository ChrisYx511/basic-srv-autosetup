#!/bin/bash

## Downloading Initial Packages for basic server setup
#  with ZFS and Cockpit projetct, shared on SMB with v1 disabled, VMs installed
#  on Ubuntu (Server)
## THIS ONLY WORKS FOR THE STOCK KERNEL, AS IT DOESN'T CONFIGURE ZFS DKMS 

echo "Run as a Standard User!"
if [[ $(cat /etc/*release | grep DISTRIB_ID=) = 'DISTRIB_ID=Ubuntu' ]]; then


    echo "Installing Upgrades"
    sudo apt update && sudo apt upgrade -y
    echo "Installing packages in repositories"
    sudo apt install -y zfsutils-linux openssh-server curl wget qemu-system qemu-utils ovmf libvirt-clients libvirt-daemon libvirt-bin virt-manager network-manager cockpit cockpit-networkmanager cockpit-docker cockpit-packagekit cockpit-machines python3 python3-pip samba nfs-kernel-server nfs-common

    echo "Done!"

    echo "Installing docker from docker repositories"
    ## Instructions from docker documentation
    # Remove old versions
    sudo apt-get remove docker docker-engine docker.io containerd runc -y
    # Repo over HTTPS
    sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    # Docker Repo GPG Key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    # Add Repository
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    # Update Package Index
    sudo apt update
    # Install Docker
    sudo apt install docker-ce docker-compose -y


    echo "All Done!, system will now reboot"
    wait 3
    reboot
else
    echo "Unsupoorted Distro! Exiting..."
    exit
fi