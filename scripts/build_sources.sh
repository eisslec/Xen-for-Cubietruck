#!/bin/bash
#Author: Christian Eissler
#Last change: 06.06.14
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
make CROSS_COMPILE=arm-linux-gnueabihf- -j 4

cp spl/sunxi-spl.bin ../../build/temp/
cp u-boot.img ../../build/temp/
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
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=output modules_install
cp ../configuration_files/multi_v7_defconfig arch/arm/configs/

make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- multi_v7_defconfig
make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=output modules_install

cp arch/arm/boot/zImage ../../build/temp/
cp arch/arm/boot/dts/sun7i-a20-cubietruck.dtb ../../build/temp/

#Check if already a old module is available
if [ ! -d ../../build/modules]; then
    rm -r ../../build/modules/*
else
    mkdir ../../build/modules
fi

cp -r output/lib/modules/* ../../build/temp/modules/
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

make dist-xen XEN_TARGET_ARCH=arm32 CROSS_COMPILE=arm-linux-gnueabihf- CONFIG_EARLY_PRINTK=sun7i
cp xen/xen ../../build/temp/

#Build Mini-OS guest demonstration
cd extras/mini-os/
make
cp mini-os ../../../../build/temp/mini-os.img
cd ../../../

#Go to the main project dir
cd ..
