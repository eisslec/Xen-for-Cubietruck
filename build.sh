#!/bin/bash
#Author: Christian Eissler
#Last change: 26.06.14

#Skript to create a XEN-Demonstation.
#Skript building XEN, creating a compatible dom0 kernel which can also be used for domU


export SOURCE_DIR=$PWD"/src"
export CONFIGURATION_DIR=$PWD"/configuration_files"

#Create needed folders
mkdir build
mkdir build/temp
mkdir build/images

#Read the configuration
echo -----------------------Read configuration----------------------------------------

export domU_count=0
export domU_list=0
export dom0=0

#Check the skript parameters
for i in "$@"
do
    case $i in
        --add_domU=*)
            domU_list[domU_count]=`echo $i | cut -d '=' -f 2`
            ((domU_count++))
        ;;
         --dom0=*)
            dom0=`echo $i | cut -d '=' -f 2`
        ;;
    esac

done

echo ------------------------Installing development tools--------------------------------

sudo apt-get install git  build-essential rsync gcc-arm-linux-gnueabihf libfdt-dev linaro-image-tools


echo --------------------Cloning the repositories and build the sources-------------------

source ./scripts/build_sources.sh


echo ------------------------Download Rootfs and Deploy files------------------------------------

source ./scripts/create_rootfs.sh


echo -----------------------Create SD-Card image ------------------------------------------------

source ./scripts/create_sd_card_image.sh

exit 0
