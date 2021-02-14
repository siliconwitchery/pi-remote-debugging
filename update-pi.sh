#!/bin/sh

# Exit on error and enable echo escape flags

set -e


# Fully update the Pi

echo "\nFull update, this will take a while\n"
apt update
apt -y full-upgrade


# Install a few extra tools for later

apt -y install git tmux cryptsetup


# Cleanup old packages

apt -y autoremove


# And reboot to start any new services

echo "\nEverything updated. Rebooting.."
reboot now