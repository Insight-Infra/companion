#!/usr/bin/env bash

# setup raspbian / raspberry pi configuration files
# /boot/cmdline.txt and
# /boot/config.txt

. $COMPANION_DIR/scripts/bash-helpers.sh

# Disable camera LED
run_step sudo sed -i '\%disable_camera_led=1%d' /boot/config.txt
run_step sudo sed -i '$a disable_camera_led=1' /boot/config.txt

# Enable RPi camera interface
run_step sudo sed -i '\%start_x=%d' /boot/config.txt
run_step sudo sed -i '\%gpu_mem=%d' /boot/config.txt
run_step sudo sed -i '$a start_x=1' /boot/config.txt
run_step sudo sed -i '$a gpu_mem=128' /boot/config.txt

#Delete ip address if present from /boot/cmdline.txt
# e.g. sed command removes any ip address with any combination of digits [0-9] between decimal points
sudo sed -i -e 's/\s*ip=[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*//' /uboot/cmdline.txt || sudo sed -i -e 's/\s*ip=[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*//' /boot/cmdline.txt

# remove any line containing 'enable_uart=' from /boot/config.txt
run_step sudo sed -i '/enable_uart=/d' /boot/config.txt
# Remove any console serial configuration
run_step sudo sed -e 's/console=serial[0-9],[0-9]*\ //' -i /boot/cmdline.txt

## Navigator
# Remove any configuration related to i2c and spi/spi1 and do the necessary changes for navigator

for STRING in "i2c-dev" "i2c-bcm2708"; do
    run_step sudo sed -i "/$STRING/d" /etc/modules
    run_step sudo sh -c "echo $STRING >> /etc/modules"
done

for STRING in "dtparam=i2c_arm=" "dtparam=spi=" "dtoverlay=spi1" "dtoverlay=uart1"; do
    run_step sudo sed -i "/$STRING/d" /boot/config.txt
done

for STRING in "dtparam=i2c_arm=on" "dtparam=spi=on" "dtoverlay=spi1-3cs" "dtoverlay=uart1"; do
    run_step sudo sh -c "echo $STRING >> /boot/config.txt"
done

# allow wifi (country code should already be set in /etc/wpa_supplicant/wpa_supplicant.conf)
run_step sudo rfkill unblock all
run_step sudo wpa_cli -i wlan0 reconfigure
