#!/bin/sh
# Exit on error
set -e


# Install cryptsetup if it isn't installed already
echo "Checking if cryptsetup is installed: "
if ! command -v cryptsetup
then
    sudo apt -y install cryptsetup
    echo "\nCryptsetup installed. Re-run this script after reboot.."
    sudo reboot now
    exit
fi


# Asks the user to change the default password
passwd


# Install a firewall and allow SSH access only
sudo apt -y install ufw
sudo ufw allow ssh
sudo ufw --force enable


# Home folder encryption
#
# Why: The SD card is completely unencrypted by default. 
#      Anyone can plug it into another computer and see the
#      contents of your whole system.
#   
# How: Fully encrypting the SD card would cause a lot of
#      overhead as the Pi has no dedicated encryption hardware.
#      Instead we can encrypt our home folder and keep any
#      sensitive information there. We will set up a virtual
#      drive, encrypt it, and then mount it over the existing
#      Pi home directory.

# Allocate an empty file which will become our secure disk
read -p "Specify a size for your encrypted home folder in \
gigabytes (enter a number, eg. 8): " sec_flie_size
sudo fallocate -l ${sec_flie_size}G /crypt-home-data
sudo dd if=/dev/zero of=/crypt-home-data bs=1M count=${sec_flie_size}k status=progress

# Encrypt the file we made
echo "Encrypting folder, answer YES to the question and \
create a password for the encrypted folder."
sudo cryptsetup -y luksFormat /crypt-home-data

# Open and mount as a mapped disk
echo "Done. Enter the password again to mount and format the folder"
sudo cryptsetup luksOpen /crypt-home-data crypt-home

# Format the drive
sudo mkfs.ext4 -j /dev/mapper/crypt-home

# Append .profiles to automatically load the encrypted disk
# at startup
echo "sudo cryptsetup luksOpen /crypt-home-data crypt-home
sudo mount /dev/mapper/crypt-home /home/pi
cd ~
$(cat ~/.profiles)" > ~/.profiles

# Reboot
echo "/nSecurity configured. Rebooting.."
sudo reboot now


# Note: It's possible to skip mounting the new pi folder at
#       login by pressing <Ctrl-C> at the unlock prompt.


# TODO SSH key login