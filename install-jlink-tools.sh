#!/bin/sh

# Exits on error and enable echo escape flags

set -e


# Create the tools directory in root
echo "\nMaking /tools directory. Ignore error if it already exists"
mkdir /tools


# Download and extract the gcc toolchain
wget --post-data ‘accept_license_agreement=accepted&non_emb_ctr=confirmed&submit=Download+software’ https://www.segger.com/downloads/jlink/JLink_Linux_arm64.tgz
tar -xf JLink_Linux_arm64.tgz
mkdir ~/tools/jlink
mv JLink_Linux_V*/** ~/tools/jlink
rm -r JLink_Linux_V*
cp ~/tools/jlink/99-jlink.rules /etc/udev/rules.d/


# Reboot to enable USB driver
echo "/nDone. Rebooting to enable USB driver"
reboot now