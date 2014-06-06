#!/bin/bash
#Author: Christian Eissler
#Last change: 06.06.14

#Skript to configure the dom0

#Check the commandline parameters
if [$# -gt 0]; then
VIRTUAL_DEVICE_NAME = $0
else
VIRTUAL_DEVICE_NAME = mmcblk0p2
fi


#Setting up the network
ifup eth0
ip addr show dev eth0

/etc/init.d/networking restart

#Install nano
apt-get install nano

#Install openssh
apt-get install openssh-server

#Go to the root directory and configure the openssh
cd
mkdir .ssh
touch .ssh/authorized_keys

#Start ssh
/etc/init.d/ssh start


#Install XEN toolstack

apt-get install update-manager-core python-apt

#Get the newest release (takes loooooong time!!! How about a cup of coffee?)
do-release-upgrade -d

dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

#Install the xen toolstack
apt-get install xen-utils-4.4

#Install LVM for the virtual disks
apt-get install lvm2

#Select the physical volume/partition where you want to install the guest systems.
#Warning!!! All data on this physical volume/partition is lost
pvcreate /dev/${VIRTUAL_DEVICE_NAME}

#Create a volume group
vgcreate vg0 /dev/${VIRTUAL_DEVICE_NAME}


#lvcreate depents on the guest system. The first can be used for the mini-os
#lvcreate -L 8M vg0 --name mini-os
#lvcreate -L 4G vg0 --name ${GUEST_NAME} #for bigger guests

#Start the guest(Great moment)
#xl create mini-os.config

#Show the running guest
#xl list
