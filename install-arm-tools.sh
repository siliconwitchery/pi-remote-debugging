#!/bin/sh

# Exits on error and enable echo escape flags

set -e


# Create the tools directory in root
echo "\Creating the /tools directory"
mkdir -p /tools


# Download and extract the ARM toolchain
cd /tools
wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/10-2020q4/gcc-arm-none-eabi-10-2020-q4-major-aarch64-linux.tar.bz2
tar -xf gcc-arm-none-eabi-10-2020-q4-major-aarch64-linux.tar.bz2 -C /tools/
mkdir /tools/arm-none-eabi
mv gcc-*/** /tools/arm-none-eabi
rm -r gcc-*


# Done
echo "Done"