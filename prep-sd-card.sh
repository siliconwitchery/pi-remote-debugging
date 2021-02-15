#!/bin/sh

# Exit on error
set -e

# Get the path to the SD card
read -p "Enter path to sd card. (On Mac it's /Volumes/boot): " sd_root

# Switch to the SD card directory
cd $sd_root

# Create the SSH file which will enable SSH access to the Raspberry Pi
touch ssh

# Ask the user for wifi credentials
read -p "Enter country code (eg. SE, DE, US, GB): " wifi_cc
read -p "Enter WiFi SSID: " wifi_ssid
read -p "Enter WiFi password: " wifi_password

# Creates a file with the 
cat <<EOF > wpa_supplicant.conf
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=$wifi_cc
network={
   ssid="$wifi_ssid"
   psk="$wifi_password"
}
EOF

echo "Done. Insert the SD card into your Raspberry Pi"