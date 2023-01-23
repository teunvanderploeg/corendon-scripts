# Install packages 
sudo apt install ipset iptables netfilter-persistent ipset-persistent iptables-persistent -y


# Clean the firewall rules
sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
sudo iptables -t nat -X


# Create the inset whitelisted
sudo ipset create whitelisted hash:ip


# Start netfilter-persistents
sudo systemctl enable netfilter-persistent
sudo systemctl start netfilter-persistent


# Filter the table and add a line to FORWARD chain, dropping everything that doesn't match the whitelisted
sudo iptables -t filter -A FORWARD -i wlan0 -m set ! --match-set whitelisted src -j REJECT


# Filter the table and add a line to FORWARD chain, in the nat table, accepting everything that matches the whitelisted
sudo iptables -t nat -I PREROUTING -i wlan0 -m set --match-set whitelisted src -j ACCEPT


# Add a line to the PREROUTING chain, in the nat table. With incoming interface wlan0, when the protocol is tcp and destination port is 80, forward it to 192.168.X.X;80
sudo iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 80 -j DNAT  --to-destination  192.168.137.121:80


# Add a line to the PREROUTING chain, in the nat table. With incoming interface wlan0, when the protocol is tcp and destination port is 443, forward it to 192.168.X.X:443
sudo iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 443 -j DNAT --to-destination  192.168.137.121:443

# Block a porn site so the users cant watch porn on the airplane
sudo iptables -I FORWARD -s 66.254.114.41 -j DROP

# Masqerade all traffic
sudo iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE

# Save the netfilter
sudo netfilter-persistent save
