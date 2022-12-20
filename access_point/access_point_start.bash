#! /usr/bin/bash
# stop the dnsmasq service
sudo systemctl stop dnsmasq

# stop the hostapd service
sudo systemctl stop hostapd

# restart dhcpcd to set up wlan0 configuration
sudo service dhcpcd restart

# start dnsmasq
sudo systemctl start dnsmasq

# make sure you can use the hostapd service
sudo systemctl unmask hostapd

# this enables the hostapd service
sudo systemctl enable hostapd

# if an interface is blocked, it will be unblocked
sudo rfkill unblock all

# this makes sure you can use hostapd.service
sudo systemctl unmask hostapd.service

# this starts the hostapd service
sudo systemctl start hostapd

# gives the status of hostapd
sudo systemctl status hostapd

# gives the status of dnsmasq
sudo systemctl status dnsmasq
