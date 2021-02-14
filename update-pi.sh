#!/bin/sh

# Fully update the Pi
sudo apt update
sudo apt full-upgrade

# Install a few extra tools for later
sudo apt install git tmux cryptsetup

# And reboot to start any new services
sudo reboot