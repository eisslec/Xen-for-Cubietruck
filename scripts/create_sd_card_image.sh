#!/bin/bash
#Author: Christian Eissler
#Last change: 26.06.14
# Create a filesystem on the sd-card and write the bootloader and the image on the sd-card

#IMAGE_SIZE=1500

#Parameter: folder
#Return: size
getFolderSize() {
    sizeValue=$(du -ks $1 | cut -f1)

    sizeValue=$((sizeValue+(sizeValue/2)))
    echo $sizeValue
}

#Create the image file
#Parameter: name, imageFolder, size, delete image folder flag
createImage() {

    IMAGE_FILE="../images/"$1".img"

    #Create Image file and a partition
    qemu-img create $IMAGE_FILE $3"k"

    LOOP_DEVICE=$(sudo losetup -f)

    echo "Current Loop device: "$LOOP_DEVICE
    sudo losetup $LOOP_DEVICE $IMAGE_FILE
    sudo parted -s $LOOP_DEVICE mklabel msdos
    sudo parted -s $LOOP_DEVICE unit cyl mkpart primary ext4 0% 100%
    sudo parted -s $LOOP_DEVICE set 1 boot on
    sudo mkfs.ext4 $LOOP_DEVICE"p1"

    #Mount the image
    if [ ! -d temp_mount ]; then
        mkdir temp_mount
    fi
    sudo mount $LOOP_DEVICE"p1" temp_mount/


    echo Copy files to image...

    if [ $4 -ne 0 ] ; then
        sudo mv $2/* temp_mount/
        sudo rm -r $2
    else
        sudo cp -a $2/. temp_mount/
    fi

    sync

    #Umount the image
    sudo umount temp_mount/
    sudo losetup -d $LOOP_DEVICE"p1"
    sudo losetup -d $LOOP_DEVICE
}

cd build/temp

export domUSize=0

#Get dom0 folder size
dom0Size=`getFolderSize "dom0"`


#Calculate the image sizes
a=0
dom0FullImageSize=$((dom0Size+500000))

for i in "${domU_list[@]}"
do
    domUSize[$a]=`getFolderSize "domU_"$i`

    echo $i "--Size" ${domUSize[$a]}

    dom0FullImageSize=$((dom0FullImageSize+domUSize[$a]))

    a=$((a+1))
done

echo "dom0FullImageSize: " $dom0FullImageSize


#Create the dom0 images
createImage "dom0" "dom0" $dom0Size 0
createImage "dom0_full" "dom0" $dom0FullImageSize 1

#Create dom0Full mount folder
if [ ! -d temp_dom0_full_mount ]; then
    mkdir temp_dom0_full_mount
fi

#sudo mount -o loop ../images/dom0_full.img temp_dom0_full_mount/
LOOP_DEVICE_FULL=$(sudo losetup -f)
sudo losetup $LOOP_DEVICE_FULL ../images/dom0_full.img
sudo mount $LOOP_DEVICE_FULL"p1" temp_dom0_full_mount/


#Create all DomU guests and copy them to the full image
a=0
for i in "${domU_list[@]}"
do   
    createImage "domU_"$i "domU_"$i ${domUSize[$a]} 1

   #Copy the guest to the dom0_full image
   sudo cp "../images/domU_"$i".img" temp_dom0_full_mount/boot/

   a=$((a+1))
done

#Umount the full image
sudo umount temp_dom0_full_mount/
sudo losetup -d $LOOP_DEVICE_FULL"p1"
sudo losetup -d $LOOP_DEVICE_FULL

cd ../../
