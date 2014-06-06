#!/bin/bash
#Author: Christian Eissler
#Last change: 06.06.14
# Create and configure the rootfilesystems

FILESYSTEM = linaro-saucy-developer-20140414-653
FILESYSTEM_LINK = https://snapshots.linaro.org/ubuntu/images/developer/latest/linaro-saucy-developer-20140414-653.tar.gz

#FILESYSTEM_LINK  https://releases.linaro.org/13.04/ubuntu/quantal-images/nano/linaro-quantal-nano-20130422-342.tar.gz

#Go to temporary build directory
cd build/temp


#Download the filesystem
wget $FILESYSTEM_LINK

tar xfvz ${FILESYSTEM} -C ./


#Configure the filesystem
cp ../configuration_files/fstab binary/etc/fstab
cp ../configuration_files/resolve.conf binary/etc/resolve.conf
cp ../configuration_files/interfaces binary/etc/network/interfaces
cp ../configuration_files/init.sh binary/boot/init.sh
cp ../configuration_files/dom0_configure.sh binary/boot/dom0_configure.sh
cp mini-os.config binary/boot/
cp mini-os.img binary/boot/
cp zImage binary/boot/
cp sun7i-a20-cubietruck.dtb binary/boot/

#Compile the bootscript
mkimage -A arm -T script -d ../configuration_files/boot.xen binary/boot.scr

cd binary
#Packing the image into a tar.gz
sudo tar -pczf ../DOM0_image.tar.gz *
cd ..
