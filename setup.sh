#!/bin/sh

# Exit on error and enables echo escape characters
set -e


# Update repos
sudo apt update


# Install TMUX and start so we don't loose the session of SSH disconnects
sudo apt -y install tmux
tmux


# Do a full update, and clean up old packages. This can take a while
sudo apt -y full-upgrade
sudo apt -y autoremove


# Install these additional tools:
#   git             For version control
#   cryptsetup      Encrypting files
#   ufw             A simple firewall
#   neovim          A nice code editor
#   nodejs          Require for some nvim tools
#   npm             We need yarn for some nvim tools
#   clang-tools     Required for autocompletion/intellisense
#   ripgrep         A better file search, used by nvim plugins
#   fzf             A fuzzy file search, used by nvim plugins
#   libncurses5     Required to run GDB on ARM64
#   zsh             A nicer shell
#
sudo apt -y install git cryptsetup ufw neovim nodejs npm clang-tools \
    ripgrep fzf libncurses5 zsh


# We'll keep other tools in the tools directory
sudo mkdir -p /tools


# Download and extract the ARM GCC toolchain, and clean up once done
curl -fSL https://developer.arm.com/-/media/Files/downloads/gnu-rm/10-2020q4/\
    gcc-arm-none-eabi-10-2020-q4-major-aarch64-linux.tar.bz2 \
    --output gcc-arm-none-eabi.bz2
tar -xf gcc-arm-none-eabi.bz2
sudo mv gcc-arm-none-eabi-*/ /tools/gcc-arm-none-eabi
rm gcc-arm-none-eabi.bz2


# Download and extract the J-LINK tools. Copies rule file & cleans up once done
curl -fSL -X POST -d \
    'accept_license_agreement=accepted&non_emb_ctr=confirmed&submit=Download+software' \
    https://www.segger.com/downloads/jlink/JLink_Linux_arm64.tgz \
    --output JLink_Linux_arm64.tgz
tar -xf JLink_Linux_arm64.tgz
sudo mv JLink_Linux_V* /tools/jlink
rm JLink_Linux_arm64.tgz


# Enable J-Link USB driver by copying the rule file
sudo cp /tools/jlink/99-jlink.rules /etc/udev/rules.d/


# Install ctags - We can't use the one from apt, so build from source
sudo git clone https://github.com/universal-ctags/ctags.git /tools --depth=1
cd /tools/ctags
sudo ./autogen.sh
sudo ./configure
sudo make
sudo make install


# Allow SSH through firewall
#
# Note: Remember to update this whenever you need to enable a new service
#
echo "\nSetting up firewall\n"
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
#
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
sudo fallocate -l ${sec_flie_size}G /crypt-home-data
sudo dd if=/dev/zero of=/crypt-home-data bs=1M \
    count=${sec_flie_size}k status=progress


# Encrypt the file we made
echo "\nAnswer YES to the question and create a password for the folder."
sudo cryptsetup -y luksFormat /crypt-home-data


# Open and mount as a mapped disk
echo "\nDone. Enter the password again to mount and format the folder\n"
sudo cryptsetup luksOpen /crypt-home-data crypt-home


# Format the drive
sudo mkfs.ext4 -j /dev/mapper/crypt-home


# Append .profile and .zprofile to automatically load the disk at startup
cat <<EOF > /home/pi/.profile
sudo cryptsetup luksOpen /crypt-home-data crypt-home
sudo mount /dev/mapper/crypt-home /home/pi
sudo chown pi:pi /home/pi
cd ~
EOF
ln -s .profile .zprofile


# Mount the new encrypteddrive
sudo mount /dev/mapper/crypt-home /home/pi                                                                                                    
sudo chown pi:pi /home/pi                                                                                                                     
cd ~ 


# Get a nice starting vim configuration.
git clone https://github.com/siliconwitch/nvim-init.git ~/.config/nvim
mkdir -p ~/.config/nvim
ln -s ~/projects/nvim-init/init.vim ~/.config/nvim/init.vim


# Install plug for nvim
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'


# Install neovim plugins
echo "Installing plugins\n" 
nvim +PlugInstall -c "CocInstall -sync coc-clangd coc-explorer" +qall


# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Download a theme and create symlink
git clone https://github.com/dracula/zsh.git ~/projects/dracula
ln -s ~/projects/dracula/dracula.zsh-theme ~/.oh-my-zsh/themes/dracula.zsh-theme


# Download custom zsh configuration and apply as default shell

sudo chsh -s $(which zsh) pi


# Download custom tmux configuration 

# Reboot
sudo reboot
