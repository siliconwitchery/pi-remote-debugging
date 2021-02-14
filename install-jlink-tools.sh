#!/bin/sh

# Exits on error and enable echo escape flags

set -e


# Create the tools directory in root
echo "\nCreating the /tools directory\n"
mkdir -p /tools


# Download the J-Link tools
curl -fSL -X POST -d 'accept_license_agreement=accepted&non_emb_ctr=confirmed&submit=Download+software' https://www.segger.com/downloads/jlink/JLink_Linux_arm64.tgz --output JLink_Linux_arm64.tgz

# Extract
echo "\nExtracting..\n"
tar -xf JLink_Linux_arm64.tgz


# Move it to the tools folder
mv JLink_Linux_V*/** /tools/jlink


# Copy the rules file
cp /tools/jlink/99-jlink.rules /etc/udev/rules.d/


# Remove archive
rm JLink_Linux_arm64.tgz


# Reboot to enable USB driver
echo "Done. Rebooting to enable USB driver"
reboot now