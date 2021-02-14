#!/bin/sh

# Exit on error and enable echo escape flags

set -e


# Fully update the Pi

sudo apt update
sudo apt -y full-upgrade


# Install a few extra tools for later

sudo apt -y install git tmux cryptsetup


# Cleanup old packages

sudo apt -y autoremove


# And reboot to start any new services

echo "\nEverything updated. Rebooting.."
sudo reboot