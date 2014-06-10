#!/bin/bash
#Author: Christian Eissler
#Last change: 06.06.14

#Skript to create a XEN-Demonstation.
#Skript building XEN, creating a compatible dom0 kernel which can also be used for domU


export SOURCE_DIR=$PWD"/src"
export CONFIGURATION_DIR=$PWD"/configuration_files"

#Create needed folders
mkdir build
mkdir build/temp
mkdir build/images

#Read the configuration
echo Read configuration

#TODO

echo ------------------------Installing development tools--------------------------------

sudo apt-get install git  build-essential rsync gcc-arm-linux-gnueabihf libfdt-dev linaro-image-tools


echo --------------------Cloning the repositories and build the sources-------------------

source ./scripts/build_sources.sh


echo ------------------------Download Rootfs and Deploy files------------------------------------

source ./scripts/create_rootfs.sh


exit 0



#Copy u-boot binaries
#cp ../src/u-boot-sunxi/spl/sunxi-spl.bin binary/boot/sunxi-spl.bin
#cp ../src/u-boot-sunxi/u-boot.img hwpack/bootloader/u-boot.img
