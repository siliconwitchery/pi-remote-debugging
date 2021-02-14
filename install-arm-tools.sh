#!/bin/sh

# Exits on error and enable echo escape flags

set -e


# Create the tools directory in root
echo "\nCreating the /tools directory\n"
mkdir -p /tools


# Download the ARM toolchain
curl -fSL https://developer.arm.com/-/media/Files/downloads/gnu-rm/10-2020q4/gcc-arm-none-eabi-10-2020-q4-major-aarch64-linux.tar.bz2 --output gcc-arm-none-eabi.bz2


# Extract
echo "\nExtracting..\n"
tar -xf gcc-arm-none-eabi.bz2


# Move it to the tools folder
mv gcc-arm-none-eabi-*/ /tools/gcc-arm-none-eabi


# Remove old files
rm gcc-arm-none-eabi-*.tar*


# Done
echo "Done\n"