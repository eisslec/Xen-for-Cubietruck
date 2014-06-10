#!/bin/bash
#Author: Christian Eissler
#Last change: 06.06.14
# Create and configure the rootfilesystems

FILESYSTEM=linaro-saucy-nano-20140126-627
FILESYSTEM_LINK=https://releases.linaro.org/14.01/ubuntu/saucy-images/nano/linaro-saucy-nano-20140126-627.tar.gz

#FILESYSTEM_LINK  https://releases.linaro.org/13.04/ubuntu/quantal-images/nano/linaro-quantal-nano-20130422-342.tar.gz

#Go to temporary build directory
cd build/temp


#Download the filesystem
if [ ! -f $FILESYSTEM".tar.gz" ]; then
    wget $FILESYSTEM_LINK
fi

tar xfvz $FILESYSTEM".tar.gz"


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

#Copy files to hwpackage
cp $CONFIGURATION_DIR/fstab binary/etc/fstab
cp $CONFIGURATION_DIR/resolv.conf binary/etc/resolve.conf
cp $CONFIGURATION_DIR/interfaces binary/etc/network/interfaces

cp $CONFIGURATION_DIR/init.sh binary/boot/init.sh
cp $CONFIGURATION_DIR/dom0_configure.sh binary/boot/dom0_configure.sh
cp $CONFIGURATION_DIR/mini-os.config binary/boot/mini-os.config

#Compile the bootscript
mkimage -A arm -T script -d $CONFIGURATION_DIR/boot.xen binary/boot/boot.scr

#Pack the filesystem
tar cfvz ../images/dom0.tar.gz  binary/

cd ../../

