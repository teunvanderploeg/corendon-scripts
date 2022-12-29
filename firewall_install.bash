# Install packages
sudo apt install ipset iptables netfilter-persistent ipset-persistent iptables-persistent -y


# Create the inset whitelisted
sudo ipset create whitelisted hash:ip


# Add and remove an ip form the ipset (Teun)
# sudo ipset add whitelisted 1.1.1.1
# sudo ipset del whitelisted 1.1.1.1


# Start netfilter-persistents
sudo systemctl enable netfilter-persistent
sudo systemctl start netfilter-persistent


# Filter the table and add a line to FORWARD chain, dropping everything that doesn't match the whitelisted
iptables -t filter -A FORWARD -i wlan0 -m set ! --match-set whitelisted src -j DROP


# Filter the table and add a line to FORWARD chain, in the nat table, accepting everything that matches the whitelisted
iptables -t nat -I PREROUTING -i wlan0 -m set --match-set whitelisted src -j ACCEPT


# Add a line to the PREROUTING chain, in the nat table. With incoming interface wlan0, when the protocol is tcp and destination port is 80, forward it to 192.168.X.X;80
iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 80 -j DNAT  --to-destination  192.168.137.121:80


# Add a line to the PREROUTING chain, in the nat table. With incoming interface wlan0, when the protocol is tcp and destination port is 443, forward it to 192.168.X.X:443
iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 443 -j DNAT --to-destination  192.168.137.121:443


# Save the netfilter
sudo netfilter-persistent save