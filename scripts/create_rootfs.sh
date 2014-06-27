#!/bin/bash
#Author: Christian Eissler
#Last change: 26.06.14
# Create and configure the rootfilesystems

#Define the available linaro filesystems
filesystemNameList[0]=linaro_nano
filesystemIdentificationList[0]=linaro-saucy-nano-20140126-627
filesystemLinkList[0]=https://releases.linaro.org/14.01/ubuntu/saucy-images/nano/linaro-saucy-nano-20140126-627.tar.gz
imageSize[0]=1000

filesystemNameList[1]=linaro_developer
filesystemIdentificationList[1]=linaro-trusty-developer-20140522-661
filesystemLinkList[1]=http://releases.linaro.org/14.05/ubuntu/trusty-images/developer/linaro-trusty-developer-20140522-661.tar.gz
imageSize[1]=1000

filesystemNameList[2]=linaro_desktop
filesystemIdentificationList[2]=linaro-precise-ubuntu-desktop-20121124-560
filesystemLinkList[2]=http://releases.linaro.org/12.11/ubuntu/precise-images/ubuntu-desktop/linaro-precise-ubuntu-desktop-20121124-560.tar.gz
imageSize[2]=2000


#Configure the some variables to the build the choosen filesystem
setFilesystemConfiguration() {
    if [ $1 == linaro_nano ]; then
        number=0;
    elif [ $1 == linaro_developer ]; then
        number=1;
    elif [ $1 == linaro_desktop ]; then
        number=2;
    fi

    filesystemName=${filesystemNameList[number]};
    filesystemIdentification=${filesystemIdentificationList[number]};
    filesystemLink=${filesystemLinkList[number]};
}

#Create the whole DOM0 image with all configuartion files
createDom0Filesystem() {


    setFilesystemConfiguration $1


    #Download the filesystem
    if [ ! -f $filesystemIdentification".tar.gz" ]; then
        wget $filesystemLink
    fi

    sudo tar xfvz $filesystemIdentification".tar.gz"
    sudo chown -R $USER binary/

    cp $SOURCE_DIR/linux-sunxi/arch/arm/boot/zImage binary/boot/zImage


    cp $SOURCE_DIR/linux-sunxi/arch/arm/boot/dts/sun7i-a20-cubietruck.dtb binary/boot/sun7i-a20-cubietruck.dtb

    #Check if already a old module is available and copy the new module
    if [ ! -d binary/lib/modules ]; then
       mkdir binary/lib/modules
        cp -r $SOURCE_DIR/linux-sunxi/output/lib/modules/* binary/lib/modules
    else
        rm -r binary/lib/modules/*
       cp -r $SOURCE_DIR/linux-sunxi/output/lib/modules/* binary/lib/modules
    fi

    cp $SOURCE_DIR/xen/xen/xen binary/boot/



    cp $SOURCE_DIR/xen/extras/mini-os/mini-os binary/boot/mini-os.img

    #Copy files to filesystem
    cp $CONFIGURATION_DIR/fstab binary/etc/fstab
    cp $CONFIGURATION_DIR/resolv.conf binary/etc/resolv.conf
    cp $CONFIGURATION_DIR/interfaces binary/etc/network/interfaces

    cp $CONFIGURATION_DIR/init.sh binary/boot/init.sh
    cp $CONFIGURATION_DIR/dom0_configure.sh binary/boot/dom0_configure.sh
    cp $CONFIGURATION_DIR/mini-os.config binary/boot/mini-os.config

    #Compile the bootscript
    mkimage -A arm -T script -d $CONFIGURATION_DIR/boot.xen binary/boot/boot.scr

    #Pack the filesystem
    #tar cfvz ../images/dom0.tar.gz  binary/
    if [ ! -d dom0 ]; then
        mkdir dom0
    fi

    sudo mv binary/* dom0/
    sudo rm -r binary/

    #Remove the temp filesystem
    #sudo rm -r binary
}


#Create a xen guest image
createDomUFilesystem() {
    setFilesystemConfiguration $1

    #Download the filesystem
    if [ ! -f $filesystemIdentification".tar.gz" ]; then
        wget $filesystemLink
    fi

    sudo tar xfvz $filesystemIdentification".tar.gz"
    sudo chown -R $USER binary/

    #Copy the fs to the right folder
    if [ $1 == linaro_desktop ]; then
        sudo mv binary/boot/filesystem.dir/* binary/
    fi

    #Copy files to the filesystem
    cp $SOURCE_DIR/linux-sunxi/arch/arm/boot/zImage binary/boot/zImage

    cp $CONFIGURATION_DIR/domU_configuration_files/fstab binary/etc/fstab
    cp $CONFIGURATION_DIR/domU_configuration_files/interfaces binary/etc/network/interfaces

    #Pack the filesystem
    #tar cfvz ../images/domU_$1.tar.gz  binary/
    if [ ! -d domU_$1 ]; then
        mkdir domU_$1
    fi

    sudo mv binary/* domU_$1/
    sudo rm -r binary/

    #Remove the temp filesystem
    #sudo rm -r binary
}


#Go to temporary build directory
cd build/temp

#Delete old images
sudo rm -r ../images/*

#Create the Dom0 filesystem
createDom0Filesystem dom0

#Create all DomU guests
for i in "${domU_list[@]}"
do
   createDomUFilesystem $i
done


#Go back to main directory
cd ../../

