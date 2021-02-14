#!/bin/sh

# Exit on error and enable echo escape flags

set -e


# Install zsh

sudo apt install zsh


# Install oh-my-zsh

sh -c “$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)”


# Install a nice theme. Change this if you want

git clone https://github.com/dracula/zsh.git ~/.oh-my-zsh/themes/dracula


# Create a symlink from the theme repo to the 
# folder where zsh actually loads themes from

ln -s ~/.oh-my-zsh/themes/dracula/dracula.zsh-theme ~/.oh-my-zsh/themes/dracula.zsh-theme


# Update zshrc with paths, theme, plugins, and aliases




# Apply new configuration

source ~/.zshrc


# Done
echo "Done"