#!/bin/sh

# Exits on error and enable echo escape flags

set -e



# Install cryptsetup if it isn't installed already

echo "\nChecking if cryptsetup is installed\n"

if ! command -v cryptsetup
then
    # Install
    apt -y install cryptsetup
    echo "\nCryptsetup installed. Re-run this script after reboot"
    
    # Reboot
    reboot now
    exit
fi



# Asks the user to change the default 'raspberry' password

if passwd --status pi | grep NP
then
    passwd
fi



# Install a firewall and allow SSH access only
#
# Note: If you need to enable more ports, you should add them
#       using 'ufw allow <port_num>' and then re-enable using
#       'ufw enable'

echo "\nSetting up firewall\n"

apt -y install ufw
ufw allow ssh
ufw --force enable


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
    echo "\nEncrypted file already exists. Stopped to prevent"
    echo "overwriting. If you want to resetup this file, back it"
    echo "up with 'sudo mv /crypt-home-data /crypt-home-data.bak'"
    echo "or delete it with 'sudo rm /crypt-home-data'"
    exit
fi

# Allocate an empty file which will become our secure disk

echo "\nSpecify a size for your encrypted home folder in gigabytes"
read -p "enter a number, eg. 8: " sec_flie_size
fallocate -l ${sec_flie_size}G /crypt-home-data
dd if=/dev/zero of=/crypt-home-data bs=1M count=${sec_flie_size}k status=progress

# Encrypt the file we made

echo "\nEncrypting folder, answer YES to the question and \
create a password for the encrypted folder."
cryptsetup -y luksFormat /crypt-home-data

# Open and mount as a mapped disk

echo "\nDone. Enter the password again to mount and format the folder\n"
cryptsetup luksOpen /crypt-home-data crypt-home

# Format the drive

mkfs.ext4 -j /dev/mapper/crypt-home

# Append .profiles to automatically load the encrypted disk
# at startup

echo "Updating user ~/.profile"
echo "sudo cryptsetup luksOpen /crypt-home-data crypt-home
sudo mount /dev/mapper/crypt-home /home/pi
sudo chown pi /home/pi
cd ~" > ~/.profile


# Reboot
#
# Note: It's possible to skip mounting the new pi folder at
#       login by pressing <Ctrl-C> at the unlock prompt.

echo "\nSecurity configured. Rebooting.."
reboot now