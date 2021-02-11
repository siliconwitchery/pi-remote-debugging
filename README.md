# Develop – Flash – Debug Embedded Code from a Headless Raspberry Pi

![]()

iPad talking to a Raspberry Pi over USB-C, where the pi is debugging a Cortex M4 target over J-Link. Wild!

## Why would you do this?
This can be run cabled or completely wireless over a network, from pretty much any device with a terminal emulator. That makes it great for creating dedicated workspaces and not being chained to a desk to develop embedded code.

If you want to get fancy, you can even configure this to run automated builds onto real hardware and connect up test gear over USB.

If you're new to terminal based workflows, these instructions will get you up and running with a beautiful working environment. If you're experienced, you'll probably take just the bits you need and mould it to your preferences.

Feel free to use this as a starting point and make your own tweaks. Fork this repository so people can find where it originated, as well as other people's configurations to discover something new.

**Let's go!**

## You will need

- **Raspberry Pi 4B** – *2GB or higher*
- **Micro SD Card** – *16GB+ and way to flash it*
- **J-Link debugger** – *Or one built into a devkit like the [nRF52-DK](https://www.nordicsemi.com/Software-and-Tools/Development-Kits/nRF52-DK)* 
- **SSH terminal app** – *Or keyboard/screen/mouse if you don't want to go headless*

## 1. Prepare a Pi Image

1. Install the latest 64bit Raspberry Pi OS from [here](https://downloads.raspberrypi.org/raspios_arm64/images/) using the Raspberry Pi [Imager](https://www.raspberrypi.org/software/)

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

1. Add the line "`dtoverlay=dwc2`" to the `config.txt` file

2. Add the text "`modules-load=dwc2`" to the end of the `cmdline.txt` file

3. Insert the SD card, start your Pi and wait a couple minutes for it to boot

4. Connect using your favourite terminal app to the pi. We like [Blink](https://blink.sh) on iOS, [iTerm2](https://iterm2.com) on MacOS, and [Hyper](https://hyper.is) on Windows

   ```bash
   ssh pi@raspberrypi.local
   ```

5. Login with the password `raspberry`. Check you're on 64bit using the command `uname -m`. It should return the value: `aarch64`

#### **Everything from here on out is done on the Raspberry Pi over SSH.**

#### If it doesn't work

- There may be an error in `wpa_supplicant.conf`. Check by pinging with `ping raspberrypi.local`.
- If you get an error about DNS spoofing, you may need to remove old entries from the file `~/.ssh/known_hosts` on your local machine.

## 2. Configure Pi as USB Gadget 

These instructions are taken from [Ben Hardill's](https://www.hardill.me.uk/wordpress/2019/11/02/pi4-usb-c-gadget/) guide, but summarised here.

1. Add the line `libcomposite` to the file `/etc/modules`

   ```bash
   sudo nano /etc/modules
   # edit the file
   # Save the file and quit with
   <Ctrl-X>
   # Y <Enter> to confirm
   Y
   <Enter>
   ```

2. Add the line `denyinterfaces usb0` to the file `/etc/dhcpcd.conf`

   ```bash
   sudo nano /etc/dhcpcd.conf
   # edit the file
   # Save the file and quit with
   <Ctrl-X>
   # Y <Enter> to confirm
   Y
   <Enter>
   ```

3. Install dnsmasq

   ```bash
   sudo apt-get install dnsmasq
   ```

4. Create a file `sudo nano /etc/dnsmasq.d/usb` with following content

   ```bash
   interface=usb0
   dhcp-range=10.55.0.2,10.55.0.6,255.255.255.248,1h
   dhcp-option=3
   leasefile-ro
   ```

5. Create a file `sudo nano /etc/network/interfaces.d/usb0` with the following content

   ```bash
   auto usb0
   allow-hotplug usb0
   iface usb0 inet static
     address 10.55.0.1
     netmask 255.255.255.248
   ```

6. Create a file `sudo nano /root/usb.sh`

   ```bash
   #!/bin/bash
   cd /sys/kernel/config/usb_gadget/
   mkdir -p pi4
   cd pi4
   echo 0x1d6b > idVendor # Linux Foundation
   echo 0x0104 > idProduct # Multifunction Composite Gadget
   echo 0x0100 > bcdDevice # v1.0.0
   echo 0x0200 > bcdUSB # USB2
   echo 0xEF > bDeviceClass
   echo 0x02 > bDeviceSubClass
   echo 0x01 > bDeviceProtocol
   mkdir -p strings/0x409
   echo "fedcba9876543211" > strings/0x409/serialnumber
   echo "Ben Hardill" > strings/0x409/manufacturer
   echo "PI4 USB Device" > strings/0x409/product
   mkdir -p configs/c.1/strings/0x409
   echo "Config 1: ECM network" > configs/c.1/strings/0x409/configuration
   echo 250 > configs/c.1/MaxPower
   # Add functions here
   # see gadget configurations below
   # End functions
   mkdir -p functions/ecm.usb0
   HOST="00:dc:c8:f7:75:14" # "HostPC"
   SELF="00:dd:dc:eb:6d:a1" # "BadUSB"
   echo $HOST > functions/ecm.usb0/host_addr
   echo $SELF > functions/ecm.usb0/dev_addr
   ln -s functions/ecm.usb0 configs/c.1/
   udevadm settle -t 5 || :
   ls /sys/class/udc > UDC
   ifup usb0
   service dnsmasq restart
   ```

7. Make this file executable with

   ```bash
   sudo chmod +x /root/usb.sh
   ```

8. Edit the file `sudo nano /etc/rc.local`  

   ```bash
   # Add the following line before exit 0
   /root/usb.sh
   
   exit 0
   ```

9. Reboot and your Pi should now be an Ethernet gadget. Check it out running on iPad [here](https://www.youtube.com/watch?v=IR6sDcKo3V8&feature=emb_title). You can access it over USB Ethernet using

   ```bash
   ssh pi@10.55.0.1
   ```

**Note: You now have the option to run this either cabled or over your wireless network.**

## 3. Update everything

1. Update everything. This can take a while ☕️

   ```bash
   sudo apt update
   sudo apt full-upgrade
   sudo apt install git tmux
   ```

2. Install some handy tools

   ```bash
   
   ```

## 4. Setting up a nicer shell ([oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/))

1. Install zsh and oh-my-zsh

   ```bash
   sudo apt install zsh
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   ```

2. Get a nice theme. For example [Dracula](https://draculatheme.com)

   ```bash
   git clone https://github.com/dracula/zsh.git ~/.oh-my-zsh/themes/dracula
   ```

3. Create a link from the theme repo to the folder where zsh actually loads themes from

   ```bash
   ln -s ~/.oh-my-zsh/themes/dracula/dracula.zsh-theme ~/.oh-my-zsh/themes/dracula.zsh-theme
   ```

4. Grab our template zsh configuration `.zshrc` to get you started. It's all default except for the lines

   ```bash
   # Env paths to the J-Link and ARM GCC folders we'll set up later
   export PATH=$HOME/tools/jlink:$HOME/tools/arm-none-eabi/bin:$HOME/.local/bin:$PATH
   
   # Set the theme
   ZSH_THEME="dracula"
   
   # Some handy plugins. Find more here:
   #   https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
   plugins=(git golang history screen tmux zsh-interactive-cd zsh-autosuggestions)
   
   # These are shortcuts, for example to shutdown, insted of typing
   # 'sudo shutdown now', you can simply type 'sd'.
   alias nrfjprog="/tools/nrfjprog.sh/nrfjprog.sh"
   alias sd="sudo shutdown now"
   alias restart="sudo reboot"
   ```

5. Apply the configuration and your terminal should be transformed!

   ```bash
   source ~/.zshrc
   ```

## 5. Set up the ARM and J-Link tools

1. Make a tools folder

   ```bash
   mkdir /tools
   ```

2. Download and extract the ARM GCC toolchain 

   ```bash
   cd /tools
   sudo wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/10-2020q4/gcc-arm-none-eabi-10-2020-q4-major-aarch64-linux.tar.bz2
   sudo tar -xf gcc-arm-none-eabi-10-2020-q4-major-aarch64-linux.tar.bz2 -C /tools/
   mkdir /tools/arm-none-eabi
   mv gcc-*/** /tools/arm-none-eabi
   rm -r gcc-*
   ```

3. Download and extract the J-Link tools

   ```bash
   wget --post-data 'accept_license_agreement=accepted&non_emb_ctr=confirmed&submit=Download+software' https://www.segger.com/downloads/jlink/JLink_Linux_arm64.tgz
   tar -xf JLink_Linux_arm64.tgz
   mkdir ~/tools/jlink
   mv JLink_Linux_V*/** ~/tools/jlink
   rm -r JLink_Linux_V*
   sudo cp ~/tools/jlink/99-jlink.rules /etc/udev/rules.d/
   sudo reboot
   ```



## 6. Set up a nice editor

1. Build [neovim](https://neovim.io) from source

   ```bash
   # We need some extra tools
   sudo apt install libtool libtool-bin autoconf automake cmake g++ pkg-config unzip gettext
   
   # Clone and build the project
   git clone https://github.com/neovim/neovim.git /tools/neovim
   cd /tools/neovim
   
   # This will take a while. Go get a ☕️
   make CMAKE_BUILD_TYPE=RelWithDebInfo
   sudo make install
   ```

2. Get a nice template configuration. Tweak or replace this later

   ```bash
   git clone https://github.com/siliconwitch/nvim-init.git ~/projects
   ln -s ~/projects/nvim-init/init.vim ~/.config/nvim/init.vim
   ```

3. Start neovim and install the plugins

   ```bash
   nvim
   
   # : goes into command mode
   :PlugInstall
   
   # Wait for everything to install
   # Then quit all windows with
   :qa
   ```

   





**Encrypt home folder**





**Change password**







**Set up ssh keys**







**Change password**