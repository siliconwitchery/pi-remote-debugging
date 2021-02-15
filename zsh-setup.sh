#!/bin/sh

# Exit on error and enable echo escape flags

set -e


echo "\nInstalling zsh and oh-my-zsh\n"


# Install zsh

sudo apt -y install zsh fzf


# Install oh-my-zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended


# Install a nice theme. Change this if you want

git clone https://github.com/dracula/zsh.git ~/.oh-my-zsh/themes/dracula


# Create a symlink from the theme repo to the 
# folder where zsh actually loads themes from

ln -s ~/.oh-my-zsh/themes/dracula/dracula.zsh-theme ~/.oh-my-zsh/themes/dracula.zsh-theme


# Clone zsh autosuggestions plugin

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


# Update zshrc with paths

echo "\nUpdating PATH to include ARM and J-Link tools\n"
sed -i 's/# export PATH=.*/export PATH=\/tools\/jlink:\/tools\/gcc-arm-none-eabi\/bin:\$HOME\/\.local\/bin:\$PATH/' .zshrc


# Update .zshrc theme

echo "Updating theme\n"
sed -i 's/ZSH_THEME=.*/ZSH_THEME="dracula"/' .zshrc


# Update .zshrc plugins. Find more here
#https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins

echo "Updating plugins\n"
sed -i 's/plugins=.*/plugins=\(fzf git golang history screen tmux zsh-interactive-cd zsh-autosuggestions\)/' .zshrc


# Add aliases to .zshrc
# These are shortcuts, for example to shutdown, insted of typing
# ‘sudo shutdown now’, you can simply type ‘sd’.

printf "alias nrfjprog=\"/tools/nrfjprog.sh/nrfjprog.sh\"
alias sd=\"sudo shutdown now\"" >> .zshrc


# Apply new configuration

echo "Done\n"
sudo chsh -s $(which zsh)
zsh