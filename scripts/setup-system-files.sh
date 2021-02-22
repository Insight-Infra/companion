#!/usr/bin/env bash

# setup raspbian / raspberry pi configuration files
# /boot/cmdline.txt and
# /boot/config.txt
. $COMPANION_DIR/scripts/bash-helpers.sh

# default wireless config
run_step sudo cp $COMPANION_DIR/params/wpa_supplicant.conf.default /etc/wpa_supplicant/wpa_supplicant.conf

# copy udev rules for detecting autopilot
run_step sudo cp $COMPANION_DIR/params/100.autopilot.rules /etc/udev/rules.d/

#Copy network configuration files from Companion directory to respective configuration directories
run_step sudo cp $COMPANION_DIR/params/interfaces-eth0 /etc/network/interfaces.d/

#Source configuration for dhcp server in the default configuration files
run_step sudo sed -i "\%$COMPANION_DIR%d" /etc/dhcp/dhcpd.conf
run_step sudo sh -c "echo 'include \"$COMPANION_DIR/params/dhcpd-server.conf\";' >> /etc/dhcp/dhcpd.conf"

run_step sudo sed -i "\%$COMPANION_DIR%d" /etc/default/isc-dhcp-server
run_step sudo sh -c "echo '. $COMPANION_DIR/params/isc-dhcp.conf' >> /etc/default/isc-dhcp-server"

#Copy default network configuration to user folder
run_step cp $COMPANION_DIR/params/network.conf.default /home/pi/network.conf

run_step sh -c "echo 'alias stopscreens=\"screen -ls | grep Detached | cut -d. -f1 | awk \\\"{print \$1}\\\" | xargs kill\"' >> ~/.bash_aliases"
run_step bash -c "echo 192.168.2.2 > $HOME/static-ip.conf"

# override start timeout for networking service to prevent hang at boot in certain misconfiguraitons
run_step sudo mkdir -p /etc/systemd/system/networking.service.d
run_step sudo sh -c "echo '[Service]\nTimeoutStartSec=10' > /etc/systemd/system/networking.service.d/timeout.conf"

# source startup script
S1=". $COMPANION_DIR/.companion.rc"

# this will produce desired result if this script has been run already,
# and commands are already in place
# delete S1 if it already exists
# insert S1 above the first uncommented exit 0 line in the file
run_step sudo sed -i -e "\%$S1%d" \
-e "0,/^[^#]*exit 0/s%%$S1\n&%" \
/etc/rc.local
