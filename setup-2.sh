# Usage: 
# ------
#   Run this script AFTER running setup-1.sh.
#
# Brief:
# ------
#   Here we encrypt the user home folder and configure our system to load it
#   automatically on login. Without encryption, the home folder is fully
#   accessible on the MicroSD card.
#
#   We will also set up a nice working space for zsh, tmux and neovim.
#
# Author(s):
# -------
#   Raj Nakarja | Silicon Witchery AB


# Don't proceed if the /crypt-home-data folder already exists
if test -f "/crypt-home-data"
then
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


# Open and mount the file as a mapped disk, then format it
echo "\nDone. Enter the password again to mount and format the folder\n"
sudo cryptsetup luksOpen /crypt-home-data crypt-home
sudo mkfs.ext4 -j /dev/mapper/crypt-home


# .profile / .zprofile will automatically load the disk when the user logs in
cat <<EOF > /home/pi/.profile
sudo cryptsetup luksOpen /crypt-home-data crypt-home
sudo mount /dev/mapper/crypt-home /home/pi
sudo chown pi:pi /home/pi
cd ~
EOF
ln -s .profile .zprofile


# Mount the new encrypted drive
sudo mount /dev/mapper/crypt-home /home/pi                                                                                                    
sudo chown pi:pi /home/pi                                                                                                                     
cd ~ 


# Install neovim from snapd
echo "Installing nvim from snapd\n"
#sudo apt -y install snapd TODO REMOVE IF THIS WORKS
sudo snap install --classic nvim


# Grab a starting nvim configuration and symlink it to the nvim settings folder
echo "\nGrabbing an nvim config and putting it into ~/projects\n"
git clone https://github.com/siliconwitch/nvim-init.git ~/projects/nvim-init
mkdir -p ~/.config/nvim
ln -s ~/projects/nvim-init/init.vim ~/.config/nvim/init.vim


# Install the plug plugin manager for nvim
echo "\nInstalling nvim plugin manager & plugins\n"
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/\
plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/\
master/plug.vim'


# Install neovim plugins
nvim --headless +PlugInstall +qall


# Install CoC plugins
nvim --headless -c "CocInstall -sync coc-clangd coc-explorer" +qall


# Install python provider for nvim
python3 -m pip install --user --upgrade pynvim


# Update remote plugins
nvim --headless +UpdateRemotePlugins +qall


# Install oh-my-zsh
echo "\nInstalling oh-my-zsh\n"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/\
tools/install.sh)" "" --unattended


# Download a theme and create symlink for zsh to load it
echo "\nDownloading Dracula theme for zsh\n"
git clone https://github.com/dracula/zsh.git ~/projects/dracula
ln -s ~/projects/dracula/dracula.zsh-theme ~/.oh-my-zsh/themes/dracula.zsh-theme


# Download the autosuggestions plugin
echo "\nDownloading autosuggestions plugin\n"
git clone https://github.com/zsh-users/zsh-autosuggestions \
${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


# Download custom zsh configuration and apply as default shell
echo "\nDownloading zsh configuration as .zshrc\n"
curl -fSL https://raw.githubusercontent.com/siliconwitchery/pi-remote-debugg\
ing/main/.zshrc --output ~/.zshrc


# Download custom tmux configuration
echo "\nDownloading tmux configuration as .tmux.conf\n"
curl -fSL https://raw.githubusercontent.com/siliconwitchery/pi-remote-debugg\
ing/main/.tmux.conf --output ~/.tmux.conf


# Set zsh as default shell and reboot
echo "\nDone! Setting default shell to zsh and rebooting\n"
sudo chsh -s $(which zsh) pi
sudo reboot


# Licence:
# --------
#   These instructions and scripts are released unencumbered into the public 
#   domain.
#
#   Feel free to use this information as a starting point, suggest
#   improvements, or fork this repository so that others may find your version.
#
#   All other software installed using these scripts remain under the terms of 
#   their respective licenses.
#
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
#   AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN 
#   ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
#   CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.