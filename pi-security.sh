#!/bin/sh

# Exits on error and enable echo escape flags

set -e



# Install cryptsetup if it isn't installed already

echo "\nChecking if cryptsetup is installed\n"

if ! command -v cryptsetup
then
    # Install
    sudo apt -y install cryptsetup
    echo "\nCryptsetup installed. Re-run this script after reboot"
    
    # Reboot
    sudo reboot now
    exit
fi



# Asks the user to change the default 'raspberry' password

if sudo passwd --status pi | grep NP
then
    passwd
fi



# Install a firewall and allow SSH access only
#
# Note: If you need to enable more ports, you should add them
#       using 'ufw allow <port_num>' and then re-enable using
#       'ufw enable'

echo "\nSetting up firewall\n"

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

if test -f "/crypt-home-data"
then
    # Stop if the /crypt-home-data folder already exists
    echo "\nEncrypted file already exists. Stopped to prevent \
overwriting. If you want to resetup this file, back it up \
with 'sudo mv /crypt-home-data /crypt-home-data.bak' or \ 
or delete it with 'sudo rm /crypt-home-data'"
    exit
fi

# Allocate an empty file which will become our secure disk

echo "\nSpecify a size for your encrypted home folder in gigabytes"
read -p "enter a number, eg. 8: " sec_flie_size
sudo fallocate -l ${sec_flie_size}G /crypt-home-data
sudo dd if=/dev/zero of=/crypt-home-data bs=1M count=${sec_flie_size}k status=progress

# Encrypt the file we made

echo "\nEncrypting folder, answer YES to the question and \
create a password for the encrypted folder."
sudo cryptsetup -y luksFormat /crypt-home-data

# Open and mount as a mapped disk

echo "\nDone. Enter the password again to mount and format the folder\n"
sudo cryptsetup luksOpen /crypt-home-data crypt-home

# Format the drive

sudo mkfs.ext4 -j /dev/mapper/crypt-home

# Append .profiles to automatically load the encrypted disk
# at startup

echo "Updating user ~/.profile"
echo "sudo cryptsetup luksOpen /crypt-home-data crypt-home
sudo mount /dev/mapper/crypt-home /home/pi
cd ~
$(cat ~/.profile)" > ~/.profile


# Reboot
#
# Note: It's possible to skip mounting the new pi folder at
#       login by pressing <Ctrl-C> at the unlock prompt.

echo "\nSecurity configured. Rebooting.."
sudo reboot now