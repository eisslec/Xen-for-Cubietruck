#!/bin/bash
#Author: Christian Eissler
#Last change: 26.06.14
# Clone the needed repositories and build the applications

TARGET=Cubietruck_config

#Go to source directory
if [ -d src ]; then
    cd src
else
    mkdir src
    cd src
fi


#Download the Uboot repository
echo Download and build the Uboot repository

if [ ! -d u-boot-sunxi ]; then
    git clone -b sunxi-next https://github.com/jwrdegoede/u-boot-sunxi.git
    cd u-boot-sunxi
else
    cd u-boot-sunxi
    git pull origin sunxi-next
fi

#Build U-Boot and copy the files to the build/temp folder
make CROSS_COMPILE=arm-linux-gnueabihf- ${TARGET}
make CROSS_COMPILE=arm-linux-gnueabihf- -j4

cd ..


#Download the kernel repository
echo Download build the kernel repository

if [ ! -d linux-sunxi ]; then
    git clone -b sunxi-devel https://github.com/linux-sunxi/linux-sunxi
    cd linux-sunxi
else
    cd linux-sunxi
    git pull origin sunxi-devel
fi

#Build the kernel and copy the files to the build/temp folder
echo Build Linux kernel
cp ../../configuration_files/multi_v7_defconfig arch/arm/configs/

make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- multi_v7_defconfig
make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=output modules_install

cd ..


#Download the xen repository
echo Download and build the xen repository

if [ ! -d xen ]; then
    git clone -b stable-4.4 git://xenbits.xen.org/xen.git
    cd xen
else
    cd xen
    git pull origin stable-4.4
fi

#Build Xen
make dist-xen XEN_TARGET_ARCH=arm32 CROSS_COMPILE=arm-linux-gnueabihf-

#Build Mini-OS guest demonstration
cd extras/mini-os/
make

cd ../../../

#Go to the main project dir
cd ..
