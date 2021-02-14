#!/bin/sh

# Exits on error and enable echo escape flags

set -e


# We need some extra tools

apt install libtool libtool-bin autoconf automake cmake g++ pkg-config unzip gettext
   

# Clone and build the project

git clone https://github.com/neovim/neovim.git /tools/neovim
cd /tools/neovim
   

# This will take a while. Go get a ☕️

make CMAKE_BUILD_TYPE=RelWithDebInfo
make install


# Get a nice starting vim configuration.
# You should tweak or replace this later

git clone https://github.com/siliconwitch/nvim-init.git ~/projects
ln -s ~/projects/nvim-init/init.vim ~/.config/nvim/init.vim


# Install neovim plugins

nvim +PluginInstall +qall


# Done
echo "Done\n"