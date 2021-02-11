# Develop – Flash – Debug Embedded Code from a Headless Raspberry Pi

![]()

iPad talking to a Raspberry Pi connected to a JLink debugger and Cortex M4 target. Debugging over SSH using a terminal emulator. Wild!

## Why would you do this?
This started out as a for-fun project just to see if it was possible. However, once you realize that you're no longer cabled to your desk, you can code from anywhere, on *almost* anything. It's also a great way to avoid constantly moving debuggers and boards when switching project as each Raspberry Pi can be used as a dedicated project instance. It's cheap and easy to set up, and if you really way to get advanced, you could even have it run continuous deployments and testing on hardware.

# Let's Go!
All these instructions could have just been a shell script, however much of it is down to personal preference. 

If you're new to terminal based workflows, these instructions will get you up and running with a beautiful working environment. If you're experienced, you'll probably take just the bits you need and mould it to your preferences.

Feel free to use this as a starting point and make your own tweaks. Fork this repository so people can find where it originated, as well as other people's configurations to discover something new.

Let's go!

## Prerequisites

You will need:

- **Raspberry Pi 4B** – *2GB or higher*
- **Micro SD Card** – *16GB+ and way to flash it*
- **J-Link debugger** – *Or one built into a devkit like the [nRF52-DK](https://www.nordicsemi.com/Software-and-Tools/Development-Kits/nRF52-DK)* 
- **SSH terminal app** – *Or keyboard/screen/mouse if you don't want to go headless*
- ☕️

## 1. Prepare the Pi Image



1. Install the latest 64bit Raspberry Pi OS from [here](https://downloads.raspberrypi.org/raspios_arm64/images/) using the Raspberry Pi [Imager](https://www.raspberrypi.org/software/).

   

2. Create an empty file on the SD card called ssh. On Linux/Mac simply:

   ```bash
   touch ssh
   ```

   

3. Create an empty file on the SD card called wpa_supplicant.conf. Again:

   ```bash
   touch wpa_supplicant.conf
   ```

   

4. Configure this file with your WiFi settings ([more info](https://www.raspberrypi.org/documentation/configuration/wireless/headless.md)):

   ```bash
   ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
   update_config=1
   country=<2 country code, eg. GB, US, SE, DE>
   
   network={
   	ssid="WIFI_NAME"
   	psk="PASSWORD"
   }
   ```



1. Insert the SD card, start your Pi and wait a couple minutes for it to boot.

   

2. Connect using your favourite terminal app to the pi. We like [Blink](https://blink.sh) on iOS, [iTerm2](https://iterm2.com) on MacOS, and [Hyper](https://hyper.is) on Windows.

   ```bash
   ssh pi@raspberrypi.local
   ```

   

3. Login with the password `raspberry`. Check you're on 64bit using the command `uname -m`. It should return the value: `aarch64`



#### If it doesn't work

- There may be an error in `wpa_supplicant.conf`. Check by pinging with `ping raspberrypi.local`.
- If you get an error about host key mismatch, you may need to remove an old entry from the file `~/.ssh/known_hosts` on your local machine.



## 2. **Housekeeping**



1. Update everything with:

   ```bash
   sudo apt update
   sudo apt full-upgrade
   ```

   This can take a while.. Go get a ☕️

   

2. Install some standard tools:

   ```bash
   sudo apt install git zsh tmux
   sudo apt install git zsh tmux libtool libtool-bin autoconf automake cmake g++ pkg-config unzip gettext
   ```



## 3. Setting up a nicer shell



Bash is nice, but [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/) is better!

1. Run this on your pi:

   ```bash
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   ```

2. Get a nice theme. For example [Dracula](https://draculatheme.com).

   ```bash
   git clone https://github.com/dracula/zsh.git ~/.oh-my-zsh/themes/dracula
   ```

3. Create a link from the theme repo to the folder where zsh actually loads themes from.

   ```bash
   ln -s ~/.oh-my-zsh/themes/dracula/dracula.zsh-theme ~/.oh-my-zsh/themes/dracula.zsh-theme
   ```

4. Grab our template zsh configuration `.zshrc` to get you started. It's all default except for the lines:

   ```bash
   # Env paths to the J-Link and ARM GCC folders we'll set up later
   export PATH=$HOME/.gem/ruby/2.6.0/bin:$PATH
   
   # Set the theme
   ZSH_THEME="dracula"
   
   # Some handy plugins. Find more here:
   #   https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
   plugins=(git zsh-interactive-cd zsh-autosuggestions)
   
   # Aliases. These are shortcuts, for example to shutdown, insted
   # of tying 'sudo shutdown now'. You can do 'sd'
   ```

5. Apply the configuration by running:

   ```bash
   source ~/.zshrc
   ```



Your terminal should now be transformed!



## 4. Set up the ARM and J-Link tools

1. Make a tools folder

   ```
   mkdir ~/tools
   ```

   





**Set up arm tools**



wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/10-2020q4/gcc-arm-none-eabi-10-2020-q4-major-aarch64-linux.tar.bz2



tar -xf gcc-arm-none-eabi-10-2020-q4-major-aarch64-linux.tar.bz2 -C ~/tools/



mkdir ~/tools/arm-none-eabi



mv gcc-*/** ~/tools/arm-none-eabi



rm -r gcc-*



**Set up Jlink tools**



wget --post-data 'accept_license_agreement=accepted&non_emb_ctr=confirmed&submit=Download+software' https://www.segger.com/downloads/jlink/JLink_Linux_arm64.tgz



tar -xf JLink_Linux_arm64.tgz



mkdir ~/tools/jlink



mv JLink_Linux_V*/** ~/tools/jlink



rm -r JLink_Linux_V*



sudo cp ~/tools/jlink/99-jlink.rules /etc/udev/rules.d/



sudo reboot



**Set up a nice editor**



git clone https://github.com/neovim/neovim.git

cd ~/tools/neovim

make CMAKE_BUILD_TYPE=RelWithDebInfo

sudo make install

cd ~



/* get our nice config */



nvim



Install plugins with :PlugInstall



Quit with :quit



**Encrypt home folder**





**Change password**







**Set up ssh keys**







**Change password**