# ARM Cortex-M debugging over SSH using a Raspberry Pi and J-Link

![iPad to Raspberry Pi over USB debugging ARM Cortex M4 with J-Link](raspberry-pi-jlink-debugging.jpg)

**Perfect for** debugging remote or ground isolated targets, as well as running CI/CD directly on hardware.

## You will need

- Raspberry Pi Model 4B
- MicroSD Card
- J-Link debugger – Or supported devkit such as the [nRF52-DK](https://www.nordicsemi.com/Software-and-Tools/Development-Kits/nRF52-DK)
- Terminal app – Such as: [Blink](https://blink.sh) (iOS), [iTerm2](https://iterm2.com) (MacOS), and [Hyper](https://hyper.is) (Windows/Linux/MacOS)

## Installation

1. Get the latest 64 bit build from [here](https://downloads.raspberrypi.org/raspios_arm64/images/), and use the official [Raspberry Pi Imager](https://www.raspberrypi.org/software/) to flash your SD card

2. Create an empty file on your SD card called `ssh`, and then `wpa_supplicant.conf` with the contents shown [here](https://www.raspberrypi.org/documentation/configuration/wireless/headless.md). **Linux / MacOS** users can run this script

   ```bash
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/siliconwitchery/pi-remote-debugging/main/prep-sd-card.sh)"
   ```

3. Insert SD and boot the Pi

4. SSH using a terminal and login with the password `raspberry`

   ```bash
   ssh pi@raspberrypi.local
   ```

5. Run the initial setup script. This takes a while and triggers a reboot

   ```bash
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/siliconwitchery/pi-remote-debugging/main/setup-1.sh)"
   ```

6. Run the second script to complete the setup

   ```bash
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/siliconwitchery/pi-remote-debugging/main/setup-2.sh)
   ```

7. **Optionally** enable USB-C networking using the script

   ```bash
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/siliconwitchery/pi-remote-debugging/main/setup-usb-eth-bridge.sh)"
   ```

8. Update your login password

   ```bash
   passwd
   ```

9. Change the default hostname from `raspberrypi` to something else

   ```bash
   sudo raspi-config # [System Options] -> [Hostname] -> change it -> reboot
   ```

10. Stay up to date by periodically running the commands

    ```bash
    sudo apt update
    sudo apt full-upgrade
    nvim +PlugUpgrade +PlugUpdate +qall
    
    # ARM and J-Link tools should be updated manually by downloading and extracting them
    ```

## Usage

#### Connecting over USB

Plug your Pi to your host machine and SSH using the address

```bash
ssh pi@10.55.0.1
```

#### ARM GCC compiler

The path `/tools/gcc-arm-none-eabi/bin` is already added to `.zshrc` so you can simply call

```bash
arm-none-eabi-gcc
```

#### J-Link tools

Likewise the path `/tools/jlink` is already added to `.zshrc` 

```bash
JLinkExe
```

#### TMUX

`tmux` makes it easy to switch/split windows. It's automatically started on login. Check out this [cheat sheet](#)

#### Neovim

Launch using the command `nvim`. This configuration is used to get you started. Keybindings

```bash

```

#### Some extras

The aliases in `.zshrc` save you from typing long

```bash
# Shutdown. Same as 'sudo shutdown now'
sd
```

## Shoutouts

These articles were a great resource when we built this guide. Be sure to go check them out:
- [Blog post: **Using a Raspberry Pi as a remote headless J-Link Server** by Niall Cooling](https://blog.feabhas.com/2019/07/using-a-raspberry-pi-as-a-remote-headless-j-link-server/)
- [Youtube: **My Favourite iPad Pro Accessory: The Raspberry Pi 4** by Tech Craft](https://www.youtube.com/watch?v=IR6sDcKo3V8&t=3s)
- [Blog post: **Pi4 USB-C Gadget** by Ben Hardill](https://www.hardill.me.uk/wordpress/2019/11/02/pi4-usb-c-gadget/)
- [Blog post: **Encrypting your home directory using LUKS on Debian/Ubuntu** by François Marier](https://feeding.cloud.geek.nz/posts/encrypting-your-home-directory-using/)

## Licence

These instructions and scripts are released unencumbered into the public domain.

Feel free to use this information as a starting point, suggest improvements, or fork this repository so that others may find your version.

All other software installed using these scripts remain under the terms of their respective licenses. 

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
