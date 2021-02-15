# Pi Based Remote Embedded Debugging

![iPad to Raspberry Pi over USB debugging ARM Cortex M4 with J-Link](raspberry-pi-jlink-debugging.jpg)

This guide is a series of shell scripts which can be run on a Raspberry Pi 4 to set up a rich workflow for developing and debugging embedded hardware.

**Includes:**

- Headless operation over SSH
- Option to use wired USB-C networking
- ARM embedded toolchain
- J-Link debugging tools
- Colourful IDE style dev environment using neovim and tmux
- Encrypted user space for storing SSH keys, source code and sensitive files

**Perfect for:**

- Debugging remote targets
- Debugging ground isolated targets
- Cable free workflows
- Dedicated environments for specific projects
- Ability to easily switch workstation and re-connect from any terminal

## You will need

- **Raspberry Pi Model 4B**
- **MicroSD Card**
- **J-Link debugger** (Or supported devkit such as the [nRF52-DK](https://www.nordicsemi.com/Software-and-Tools/Development-Kits/nRF52-DK))
- **Terminal app** (Some we like: [Blink](https://blink.sh) *iOS*, [iTerm2](https://iterm2.com) *MacOS*, and [Hyper](https://hyper.is) *Windows/Linux/MacOS*)

## Installation

### Prepare the SD Card

#### 1. Install Raspberry Pi OS

Get the latest 64 bit build from [here](https://downloads.raspberrypi.org/raspios_arm64/images/). Use the official [Raspberry Pi Imager](https://www.raspberrypi.org/software/) to easily flash your SD card.

#### 2. Enable SSH and WiFi

On **Linux / MacOS** simply run this from your terminal and follow the steps:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/siliconwitchery/pi-remote-debugging/main/prep-sd-card.sh)"
```

**Or do it manually**: Create an empty file on the SD card called `ssh`, and then create a file called `wpa_supplicant.conf` with the contents shown [here](https://www.raspberrypi.org/documentation/configuration/wireless/headless.md).

#### 3. Boot the Pi and connect

Insert the MicroSD into your Pi and wait for boot. Connect over SSH using your favourite terminal app. Password is `raspberry`

```
ssh pi@raspberrypi.local
```

**If it doesn't work**: Your `wpa_supplicant.conf` file might be incorrect. Recreate it. If you get a DNS spoofing error, you'll need to clear out old entries from the `~/.ssh/known_hosts` file on your local machine.

### Setup the Pi

These scripts serve as a starting point for a good working configuration. Try them out, or read what they do and customise them for yourself. They are well commented.

**Warning**: These have only been tested on a fresh Raspberry Pi OS install. Elevated privileges are required to ensure things work correctly, however could easily wreck your system. Use them with care and read them carefully before running them on your working pi setup.

#### 1. Update the Pi

This takes a while ☕️ and will trigger a reboot. Read what it does [here]() and then run this command on your pi:

```bash
sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/siliconwitchery/pi-remote-debugging/main/update-pi.sh)"
```

#### 2. Set up security

Sets up a **firewall**, and an **encrypted home folder**. Read what it does [here](), and then run on your pi using:

```bash
sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/siliconwitchery/pi-remote-debugging/main/pi-security.sh)"
```

3. Enable USB tethering

   ```bash
   sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/siliconwitchery/pi-remote-debugging/main/pi-usb-gadget.sh)"
   ```

4. Install ARM tools

   ```bash
   sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/siliconwitchery/pi-remote-debugging/main/install-arm-tools.sh)"
   ```

5. Install J-Link tools

   ```bash
   sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/siliconwitchery/pi-remote-debugging/main/install-arm-tools.sh)"
   ```

6. Add a nicer shell

   ```bash
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/siliconwitchery/pi-remote-debugging/main/zsh-setup.sh)"
   ```

7. Install a nicer editor *Takes a while* ☕️

   ```bash
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/siliconwitchery/pi-remote-debugging/main/install-nvim.sh)"
   ```

## Housekeeping

1. Update the default `raspberry` password using the command

   ```
   passwd
   ```

2. Change the host name from `raspberrypi.local` to something else using

   ```
   sudo raspi-config
   # [System Options] -> [Hostname] -> change it -> reboot
   ```

   

## Good to go

#### Connecting over USB

The `usb-tether.sh` script sets up a static IP that allows you to connect to the Pi over its USB-C port. The Pi shows up as an ethernet device and can be connected to using the address `10.55.0.1`

```bash
ssh pi@10.55.0.1
```

#### Some handy commands

```bash
# Calling the ARM GCC compiler
arm-none-eabi-gcc

# Running J-Link commander
JLinkExE 

# For working in multiple tabs/windows inside the terminal
tmux

# For editing files
nvim

# Some handy aliases for various common tasks (change or add more in ~/.zshrc)
# git status
# git fetch & pull
# git switch branch
# git add all and commit
# shutdown
# reboot
```

#### Other handy links

- tmux cheatsheet
- Vim cheatsheet

## Shoutouts

This guide was peiced together from various articles. Check them out here
- [Blog post: **Using a Raspberry Pi as a remote headless J-Link Server** by Niall Cooling](https://blog.feabhas.com/2019/07/using-a-raspberry-pi-as-a-remote-headless-j-link-server/)
- [Youtube: **My Favourite iPad Pro Accessory: The Raspberry Pi 4** by Tech Craft](https://www.youtube.com/watch?v=IR6sDcKo3V8&t=3s)
- [Blog post: **Pi4 USB-C Gadget** by Ben Hardill](https://www.hardill.me.uk/wordpress/2019/11/02/pi4-usb-c-gadget/)

## Licence

These instructions and scripts are released unencumbered into the public domain.

Feel free to use this information as a starting point, suggest improvements, or fork this repository so that others may find your version.

All other software installed using these scripts remain under the terms of their respective licenses. 

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
