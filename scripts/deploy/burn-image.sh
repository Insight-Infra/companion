#!/usr/bin/env bash

IMAGE_FILE=$1
DEV_DISK=$2

error() {
    echo -e "ERROR: $*" >&2
    exit 1
}

input() {
    read -s -n 1 key
    if [[ $key != $* ]]; then
        echo "Exiting..."
        exit 0
    fi
}

if [[ $IMAGE_FILE == "" ]]; then
    echo "usage: ./burn-image.sh IMAGEFILE DISK [noexpand]"
    error "no image argument supplied"
fi

if [[ $DEV_DISK == "" ]]; then
    echo "usage: ./burn-image.sh IMAGEFILE DISK [noexpand]"
    error "no disk argument supplied"
fi

if [[ $3 != "noexpand" && $3 != "" ]]; then
    echo "usage: ./burn-image.sh IMAGEFILE DISK [noexpand]"
    error "unrecognized argument $3"
fi

if [[ $4 != "" ]]; then
    echo "usage: ./burn-image.sh IMAGEFILE DISK [noexpand]"
    error "too many arguments supplied"
fi

# make sure the disk is on usb
udevadm info $DEV_DISK | grep ID_BUS=usb > /dev/null

if [[ $? != 0 ]]; then
    error "$DEV_DISK is not on the USB bus!"
fi

# TODO make sure the disk contains a companion OS image
# check it is top level disk device, not a partition

# check size
# TODO learn sed/perl/awk w regex
DEV_DISK_SIZE=$(parted -s $DEV_DISK unit GB print devices | grep $DEV_DISK | cut -f2 -d' ')

# make sure the user wants to work with this disk
echo "$DEV_DISK is $DEV_DISK_SIZE"
echo "Are you sure you want to burn $IMAGE_FILE to $DEV_DISK?"
input "y"

echo "This will ERASE the contents of $DEV_DISK"
echo "Are you sure you're sure?"
input "y"

echo "unmounting $DEV_DISK"
umount $DEV_DISK?*

echo $IMAGE_FILE | grep -q .zip

if [[ $? == 0 ]]; then
    echo "extracting image..."
    IMAGE_FILE_EXTRACTED=$(echo $IMAGE_FILE | sed "s/.zip//")
    unzip $IMAGE_FILE
    IMAGE_FILE=$IMAGE_FILE_EXTRACTED
fi

dd if=$IMAGE_FILE of=$DEV_DISK bs=1MiB status=progress || error "Failed to copy $IMAGE_FILE to $DEV_DISK"

if [[ $3 == "noexpand" ]]; then
    MOUNT_LOCATION=/tmp/companion_deploy
    mkdir -p $MOUNT_LOCATION

    DEV_PART2=$DEV_DISK
    DEV_PART2+=2

    echo "mounting $DEV_DISK on $MOUNT_LOCATION"
    mount $DEV_PART2 $MOUNT_LOCATION || error "Failed to mount $DEV_PART2 on $MOUNT_LOCATION"

    EXPAND="/home/pi/companion/scripts/expand_fs.sh"
    sed -i "\%$EXPAND%d" $MOUNT_LOCATION/etc/rc.local

    echo "unmounting $DEV_DISK"
    umount $DEV_DISK?*
fi

echo "done"
