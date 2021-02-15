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
sudo make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install


# Get a nice starting vim configuration.
# You should tweak or replace this later

git clone https://github.com/siliconwitch/nvim-init.git /home/pi/projects/nvim-init
echo "\nCreating symlink to nvim configuration\n"
mkdir -p /home/pi/.config/nvim
ln -s /home/pi/projects/nvim-init/init.vim /home/pi/.config/nvim/init.vim


# Install plug for nvim

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'


# Install neovim plugins

echo "Installing plugins\n" 
nvim +PlugInstall +qall


# Done
echo "Done\n"