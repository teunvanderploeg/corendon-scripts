# config files are not ready yet, so turn software off
sudo systemctl stop dnsmasq
sudo systemctl stop hostapd

# Now restart the dhcpcd daemon and set up the new wlan0 configuration.
sudo service dhcpcd restart

# Start dnsmasq (it was stopped), it will now use the updated configuration
sudo systemctl start dnsmasq

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
