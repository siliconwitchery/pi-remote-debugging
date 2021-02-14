#!/bin/sh

# Exits on error and enable echo escape flags

set -e



# This script is assembled from these instructions by Ben Hardill
# https://www.hardill.me.uk/wordpress/2019/11/02/pi4-usb-c-gadget/

sudo printf "\nlibcomposite" >> /etc/modules

sudo printf "\ndenyinterfaces usb0" >> /etc/dhcpcd.conf

sudo apt-get install dnsmasq

sudo cat <<EOF > /etc/dnsmasq.d/usb
interface=usb0
dhcp-range=10.55.0.2,10.55.0.6,255.255.255.248,1h
dhcp-option=3
leasefile-ro
EOF

sudo cat <<EOF > /etc/network/interfaces.d/usb0
auto usb0
allow-hotplug usb0
iface usb0 inet static
address 10.55.0.1
netmask 255.255.255.248
EOF

sudo cat <<EOF > /root/usb.sh
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
EOF

exit # Make usb.sh executable

sudo chmod +x /root/usb.sh

# Append RC Local to call usb.sh on boot

sed -e '$s/exit 0/\/root\/usb.sh\nexit 0/' /etc/rc.local > ~/temp
sudo mv ~/temp /etc/rc.local

# And reboot to start any new services

echo "\nUSB Ethernet gadget set up. Rebooting.."
sudo reboot