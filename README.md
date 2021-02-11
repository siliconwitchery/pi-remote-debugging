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
6. Encruption for your home folder
7. SSH keys for easy login
8. Lots of beautification for an enjoyable workflow

Let's go!
