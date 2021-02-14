#!/bin/sh

# Exits on error and enable echo escape flags

set -e


echo "\nInstalling nvim from source\n"


# We need some extra tools

sudo apt -y install libtool libtool-bin autoconf automake cmake g++ pkg-config unzip gettext
   

# Clone and build the project

sudo git clone https://github.com/neovim/neovim.git /tools/neovim
cd /tools/neovim
   

# This will take a while. Go get a ☕️

echo "\nBuilding nvim. This will take a while\n" 
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install


# Get a nice starting vim configuration.
# You should tweak or replace this later

git clone https://github.com/siliconwitch/nvim-init.git ~/projects
echo "\nCreating symlink to nvim configuration\n" 
ln -s ~/projects/nvim-init/init.vim ~/.config/nvim/init.vim


# Install neovim plugins

echo "Installing plugins\n" 
nvim +PluginInstall +qall


# Done
echo "Done\n"