#! /usr/bin/bash
# install hostapd and dnsmasq to be able to make an access point
sudo apt install dnsmasq hostapd rfkill dhcpcd5 iptables -y

# config files are not ready yet, so turn software off
sudo systemctl stop dnsmasq
sudo systemctl stop hostapd

# Backup dhcpcd.conf
sudo mv /etc/dhcpcd.conf /etc/dhcpcd.conf.back
# to configure the static ip address, edit the dhcpcd config file
sudo cat > /etc/dhcpcd.conf << EOF
interface wlan0
    static ip_address=192.168.4.1/24
    nohook wpa_supplicant
EOF

# Now restart the dhcpcd daemon and set up the new wlan0 configuration.
sudo service dhcpcd restart

# Backup dnsmasq.conf
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.back
# The DHCP service is provided by dnsmasq. By default, the configuration file contains a lot of information that is
# not needed, and it is easier to start from scratch. Rename this configuration file, and type the information in
# the dnsmasq config filesudo service dhcpcd restart
sudo cat > /etc/dnsmasq.conf << EOF
interface=wlan0      # Use the require wireless interface - usually wlan0
dhcp-range=192.168.4.2,192.168.4.200,255.255.255.0,24h
EOF

# To use the 53 port, disable & stop the systemd-resolved service
sudo systemctl disable systemd-resolved.service

systemctl stop systemd-resolved

# Start the dnsmasq service
sudo service start

sudo systemctl enable dnsmasq

sudo systemctl start dnsmasq

# Start dnsmasq (it was stopped), it will now use the updated configuration
sudo systemctl start dnsmasq

# Backup hostapd.conf
sudo mv /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.back
# You need to edit the hostapd configuration file, located at /etc/hostapd/hostapd.conf, to add the various paramete># for your wireless network. After initial install, this will be a new/empty file.
sudo cat > /etc/hostapd/hostapd.conf << EOF
interface=wlan0
driver=nl80211
ssid=Corendon-Open-Network
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=0
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF

# Backup hostapd
sudo mv /etc/default/hostapd /etc/default/hostapd.back
# We now need to tell the system where to find this configuration file.
sudo cat > /etc/default/hostapd << EOF
DAEMON_CONF="/etc/hostapd/hostapd.conf"
EOF

# Now enable and start hostapd
sudo systemctl unmask hostapd
sudo systemctl enable hostapd

# when you get an error you can try to unmask hostapd.service, by doing this you can use hostapd.service
sudo systemctl unmask hostapd.service

# when an interface is blocked, you can unblock it by doing the following:
sudo rfkill unblock all

# start hostapd service
sudo systemctl start hostapd

# Backup sysctl.conf
sudo mv /etc/sysctl.conf /etc/sysctl.conf.back
# Edit /etc/sysctl.conf and uncomment this line:
sudo cat > /etc/sysctl.conf << EOF
net.ipv4.ip_forward=1
EOF

# Add a masquerade for outbound traffic on eth0
sudo iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE

# Save the iptables rule
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

# Backup rc.local
sudo mv /etc/rc.local /etc/rc.local.back

# Edit /etc/rc.local and add this just above  ^`^|exit 0 ^`^} to install these rules on boot.
sudo cat > /etc/rc.local << EOF
#!/bin/bash
if [ -f /aafirstboot ]; then /aafirstboot start ; fi
iptables-restore < /etc/iptables.ipv4.nat
exit 0
EOF