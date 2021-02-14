#!/bin/sh

# Exit on error
set -e

# Fully update the Pi
sudo apt update
sudo apt -y full-upgrade

# Install a few extra tools for later
sudo apt -y install git tmux cryptsetup

# And reboot to start any new services
echo "Everything updated. Rebooting.."
sudo reboot