#!/bin/sh

# Usage: 
# ------
#   Run this script first using `sh setup-1.sh`, then run setup-2.sh after
#   the automatic reboot. NOTE: Avoid loosing SSH connection as this 
#   script takes a while. It will abort if SSH is lost. Use something like
#   TMUX to keep sessions alive if your connection is flakey.
#
# Brief:
# ------
#   A Raspbian linux configuration for building ARM embedded applications
#   and flashing Cortex M targets using a J-Link debugger all from a 
#   Rapsberry Pi 4.
#
#   This configuration includes basic build and flash tools, as well as a
#   good starting IDE like setup for developing C/C++ Code.
#
#   Additionally, the pi home folder will be encrypted using LUKs based 
#   encryption to ensure safe storage of user data and sensitive
#   information.
#
# Major tools installed:
# ----------------------
#   - git
#   - tmux
#   - zsh
#   - neovim (+ some plugins & config)
#   - ARM GCC toolchain for Cortex R/M
#   - J-Link tools
#
# Author(s):
# -------
#   Raj Nakarja | Silicon Witchery AB
#

# Exit on error and enables echo escape characters
set -e


# Update repos, run a full update, and cleanup. Takes a while
echo "\nRunning full update. Will take a while\n"
sudo apt update
sudo apt -y full-upgrade
sudo apt -y autoremove


# Install tools:
#   git             For version control
#   tmux            Multitasking inside the terminal
#   cryptsetup      Encrypting files
#   nodejs          Require for some nvim tools
#   npm             We need yarn for some nvim tools
#   clang-tools     Required for autocompletion/intellisense
#   ripgrep         A better file search, used by nvim plugins
#   fzf             A fuzzy file search, used by nvim plugins
#   libncurses5     Required to run GDB on ARM64
#   zsh             A nicer shell
#   snapd           An install manager required to get nvim
#   mosh            More robust than SSH
#
echo "\nInstalling various tools\n"
sudo apt -y install git tmux cryptsetup nodejs npm clang-tools \
    ripgrep fzf libncurses5 zsh snapd mosh


# We'll keep ARM and J-Link tools in this directory
echo "\nThe /tools directory will be used to store the ARM GCC and J-Link apps\n"
sudo mkdir -p /tools


# Download the ARM GCC toolchain
echo "\nDownloading ARM GCC tools\n"
curl -fSL https://developer.arm.com/-/media/Files/downloads/gnu-rm/10-2020q4/\
gcc-arm-none-eabi-10-2020-q4-major-aarch64-linux.tar.bz2 \
--output gcc-arm-none-eabi.bz2


# Extract, move and clean up the archive
echo "\nExtracting and moving to /tools\n"
tar -xf gcc-arm-none-eabi.bz2
sudo mv gcc-arm-none-eabi-*/ /tools/gcc-arm-none-eabi
rm gcc-arm-none-eabi.bz2


# Download the J-LINK tools
echo "\nDownloading J-Link tools\n"
curl -fSL -X POST -d \
'accept_license_agreement=accepted&non_emb_ctr=confirmed&submit=Download+\
software' https://www.segger.com/downloads/jlink/JLink_Linux_arm64.tgz \
--output JLink_Linux_arm64.tgz


# Extract, move and clean up the archive
echo "\nExtracting and moving to /tools\n"
tar -xf JLink_Linux_arm64.tgz
sudo mv JLink_Linux_V* /tools/jlink
rm JLink_Linux_arm64.tgz


# Enable J-Link USB driver by copying the rule file to udev
echo "\nCopying J-Link USB driver to /ect/udev/rules.d\n"
sudo cp /tools/jlink/99-jlink.rules /etc/udev/rules.d/


# Reboot
echo "\nDone! Run setup-2.sh after the reboot\n"
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