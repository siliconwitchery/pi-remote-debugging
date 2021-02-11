# Develop – Flash – Debug Embedded Code from a Headless Raspberry Pi

![]()

Here's an iPad talking to a Raspberry Pi 4B that's connected to a JLink debugger and Cortex M4 target for remote embedded debugging on real hardware. Everything on screen just runs from a terminal, in this case over SSH using [Blink](https://blink.sh)

## Why would you do this?
Honestly we asked ourselves the same thing, but once you're no longer hooked up to a jungle of cables for your embedded debugging, all of a sudden you realise that you're free to move to a sofa, switch machine, or even head to a coffee shop and still have complete remote access to hardware running on your bench as if it were all just hooked up to your system.

# Get started
All these instructions could have just been a shell script, however much of it is down to personal preference. If you're no so familiar with linux terminal based workflow, follow these steps. Otherwise feel free to swap in your own tweaks and requirements along the way. If you want to make your own build script, we'd love for you to fork this repository so people can find this and others for more options.

In short, we will set up:

1. Raspberry Pi OS 64bit
2. Basic tools such as git and cmake
3. ARM GCC toolchain
4. J-Link debugging tools and drivers
5. A nice terminal based editor
6. Encryption for your home folder
7. SSH keys for easy login
8. Lots of beautification for an enjoyable workflow

Let's go!

## Prerequisites

You will need:

- **Raspberry Pi Model 4B** – *2GB model or higher*
- **Micro SD Card** – *16GB+ and way to flash it*
- **J-Link debugger** – *Or one built into a devkit like the [nRF52-DK](https://www.nordicsemi.com/Software-and-Tools/Development-Kits/nRF52-DK)* 
- **SSH terminal app** – *Or keyboard/screen/mouse if you don't want to go headless*
- A little patience or some ☕️

## Prepare the Pi Image

1. Install latest 64bit Raspberry Pi OS from [here](https://downloads.raspberrypi.org/raspios_arm64/images/) using the Raspberry Pi [Imager](https://www.raspberrypi.org/software/).

2. Create an empty file on the SD card called ssh. On linux/mac simply:

    `touch ssh`

3. Create an empty file on the SD card called wpa_supplicant.conf. Again:

   `touch wpa_supplicant.conf`

4. Configure this file with your WiFi settings ([more info](https://www.raspberrypi.org/documentation/configuration/wireless/headless.md)):

```
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=<2 country code, eg. GB, US, SE, DE>

network={
	ssid="WIFI_NAME"
	psk="PASSWORD"
}
```

5. Insert the SD card, start your Pi and wait a couple minutes for it to boot.

6. Connect using your favourite terminal app to the pi. We like [Blink](https://blink.sh) on iOS, [iTerm2](https://iterm2.com) on MacOS, and [Hyper](https://hyper.is) on Windows.

   `ssh pi@raspberrypi.local`

7. If it doesn't work, you may have made an error in `wpa_supplicant.conf`. Try to ping your Pi using:

   `ping raspberrypi.local`

8. Once connected, accept any messages about new host keys. If you get an error about host key mismatch, you may need to remove an old entry from the file `~/.ssh/known_hosts` on your local machine.

9. Login password is `raspberry` and you should be logged in! Check you're on the 64bit version using the command:

   `uname -m` it should return the value: `aarch64`

## **Housekeeping**

Let's update everything with:

`sudo apt update`

Then:

`sudo apt full-upgrade`

This can take a while.

Finally we need to install a bunch of standard tools and apps

`sudo apt install git zsh tmux`

sudo apt install git zsh tmux libtool libtool-bin autoconf automake cmake g++ pkg-config unzip gettext



**Set up a nice shell**



sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"



git clone https://github.com/dracula/zsh.git ~/.oh-my-zsh/themes/dracula



ln -s ~/.oh-my-zsh/themes/dracula/dracula.zsh-theme ~/.oh-my-zsh/themes/dracula.zsh-theme



/* Get our zsh configuration */



**Set up a tools folder**



mkdir ~/tools



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