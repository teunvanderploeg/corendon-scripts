#! /usr/bin/bash
# install hostapd and dnsmasq to be able to make an access point
sudo apt install dnsmasq hostapd rfkill dhcpcd5 -y

# config files are not ready yet, so turn software off
sudo systemctl stop dnsmasq
sudo systemctl stop hostapd

# to configure the static ip address, edit the dhcpcd config file
sudo cp dhcpcd.txt /etc/dhcpcd.conf

# Now restart the dhcpcd daemon and set up the new wlan0 configuration.
sudo service dhcpcd restart

# The DHCP service is provided by dnsmasq. By default, the configuration file contains a lot of information that is
# not needed, and it is easier to start from scratch. Rename this configuration file, and type the information in
# the dnsmasq config filesudo service dhcpcd restart
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
sudo cp dnsmasq.txt /etc/dnsmasq.conf

# To use the 53 port, disable & stop the systemd-resolved service
sudo systemctl disable systemd-resolved.service

systemctl stop systemd-resolved

# Start the dnsmasq service
sudo service start

sudo systemctl enable dnsmasq

sudo systemctl start dnsmasq

# Start dnsmasq (it was stopped), it will now use the updated configuration
sudo systemctl start dnsmasq

# You need to edit the hostapd configuration file, located at /etc/hostapd/hostapd.conf, to add the various paramete># for your wireless network. After initial install, this will be a new/empty file.
sudo cp hostapd.txt /etc/hostapd/hostapd.conf

# We now need to tell the system where to find this configuration file.
sudo cp hostapd_DAEMON.txt /etc/default/hostapd

# Now enable and start hostapd
sudo systemctl unmask hostapd
sudo systemctl enable hostapd

# when you get an error you can try to unmask hostapd.service, by doing this you can use hostapd.service
sudo systemctl unmask hostapd.service

# when an interface is blocked, you can unblock it by doing the following:
sudo rfkill unblock all

# start hostapd service
sudo systemctl start hostapd

# Do a quick check of their status to ensure they are active and running
sudo systemctl status hostapd
sudo systemctl status dnsmasq

# Edit /etc/sysctl.conf and uncomment this line:
sudo sed -i 's/# net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

# Add a masquerade for outbound traffic on eth0
sudo iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE

# Save the iptables rule
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

# Edit /etc/rc.local and add this just above  ^`^|exit 0 ^`^} to install these rules on boot.
sudo cp rc_local.txt /etc/rc.local
