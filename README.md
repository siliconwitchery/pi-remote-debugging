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

## Prepare Pi Image

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

#### If it doesn't work

- There may be an error in `wpa_supplicant.conf`. Check by pinging with `ping raspberrypi.local`.
- If you get an error about DNS spoofing, you may need to remove old entries from the file `~/.ssh/known_hosts` on your local machine.

## Update everything

1. Update everything on the. This can take a while ☕️

   ```bash
   sudo apt update
   sudo apt full-upgrade
   
   # We will use these later so might as well install them too
   sudo apt install git tmux cryptsetup
   
   # Make sure to reboot because some kernal things might have updated
   sudo reboot
   ```

## Improve security

#### Change default password

1. Don't stick to the default password 🙂 Change it with the command

   ```bash
   passwd
   ```

#### Home folder encryption

**Note:** This section is somewhat experimental and it's easy to mess everything up. Do it earlier rather than later to save potential screw ups.

**Why:** The SD card is completely unsecure so it's a good idea to encrypt it before deploying sensitive data onto it. It's also a good idea to change the default password and reduce attack surface using a firewall.

**How:** The Pi isn't really powerful enough to handle a fully encrypted SD card. That's okay though as long as we keep our data in a single secure place. System related things can be unsecure. Here we will set up a virtual drive, encrypt it, and then mount it on top of the user home directory. *this is a bit experimental so take it with the entire tub of salt. So far it seems to work for us.*

1. Create a virtual disk of whatever size you like. Here we use 8GB

   ```bash
   sudo fallocate -l 8G /crypt-home-data
   sudo dd if=/dev/zero of=/crypt-home-data bs=1G count=8
   ```

2. Encrypt the drive using cryptsetup

   ```bash
   sudo cryptsetup -y luksFormat /crypt-home-data
   ```

3. Open it

   ```bash
   sudo cryptsetup luksOpen /crypt-home-data crypt-home
   ```

4. Format the partition to ext4

   ```bash
   mkfs.ext4 -j /dev/mapper/crypt-home
   ```

5. Append the following to the start of the .profiles file. `nano ~/.profile`

   ```bash
   # Mount encrypted workspace
   sudo cryptsetup luksOpen /crypt-home-data crypt-home
   sudo mount /dev/mapper/crypt-home /home/pi
   cd ~
   
   ...
   otherstuff
   # <Ctrl-X> Y <Enter> to save and exit nano
   ```

8. Reboot and see if it worked

   ```bash
   sudo reboot now
   ```

**If not:** and you're no longer able to login, you'll need to mount the SD card to another Linux machine and check the files. Note that Mac and Windows can't read the ext4 filesystem, so you'll need to use a Linux VM.

#### Install a firewall

1. Be careful to do this right otherwise you'll get locked out

   ```bash
   sudo apt install ufw
   sudo ufw allow ssh
   sudo ufw enable
   ```

2. Make sure you still have access by opening a new ssh connection. **Don't close the exiting one in case you need to make changes**.

   ```bash
   ssh pi@raspberrypi.local
   ```

#### SSH key login

Right now we have two login steps. One for the SSH, and another for the encrypted drive. We can automate both of these.

// TODO

## Enable USB tethering

Rather than connecting over a wired or wireless network. You can configure the USB-C port of the Pi as a Ethernet bridge. Plug it into any computer and you'll be able to SSH over an IP address.

*These instructions are taken from [Ben Hardill's](https://www.hardill.me.uk/wordpress/2019/11/02/pi4-usb-c-gadget/) guide*

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

You'll now have the option to connect over WiFi, Ethernet or USB-C.

## 5. Nicer shell ([oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/))

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

## 5. ARM GCC and J-Link

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

   