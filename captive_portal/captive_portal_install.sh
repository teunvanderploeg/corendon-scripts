# Install apache2, wsgi, pip3 mysql-server, nodejs, npm, and git
sudo apt-get install apache2 libapache2-mod-wsgi-py3 python3-pip git mysql-server python3-virtualenv libmysqlclient-dev nodejs npm openssl -y
# enable apache2 module wsgi
sudo a2enmod wsgi
# Set Python3 as default Python
sudo ln -sf /usr/bin/python3 /usr/bin/python

# Start mysql server
sudo systemctl start mysql.service

# Get git corendon-captive-portal repository and move to correct directory
sudo git clone https://github.com/teunvanderploeg/corendon-captive-portal.git /var/www/html/captive-portal/corendon-captive-portal

# Create virtual environment
sudo virtualenv /var/www/html/captive-portal/corendon-captive-portal/venv
# Activate virtual environment
. /var/www/html/captive-portal/corendon-captive-portal/venv/bin/activate
# Installing flask module in venv
sudo pip3 install -r /var/www/html/captive-portal/corendon-captive-portal/requirements.txt

sudo a2enmod ssl
sudo openssl req -new -newkey rsa:4096 -nodes -keyout /etc/ssl/private/corendon_captive_portal.key -out /etc/ssl/certs/corendon_captive_portal.csr -subj "/C=NL/ST=Noord-Holland/L=Amsterdam/O=HVA/CN=198.168.3.2"
sudo openssl x509 -req -days 365 -in /etc/ssl/certs/corendon_captive_portal.csr -signkey /etc/ssl/private/corendon_captive_portal.key -out /etc/ssl/certs/corendon_captive_portal.crt

# Apache2 config for wsgi and flask site
sudo cat > /etc/apache2/sites-available/captive-portal.conf << EOF
<VirtualHost *:80>
  ServerName www.CaptivePortal.com
  Redirect permanent / https://www.CaptivePortal.com/
</VirtualHost>
<VirtualHost *:443>
  SSLEngine on
  SSLCertificateFile /etc/ssl/certs/corendon_captive_portal.crt
  SSLCertificateKeyFile /etc/ssl/private/corendon_captive_portal.key
  ServerName www.CaptivePortal.com
  ServerAdmin youemail@email.com
  RedirectMatch 302 /generate_204 /
  RedirectMatch 302 /connecttest.txt /
  RedirectMatch 302 /hotspot-detect.html /
  RedirectMatch 302 /canonical.html /
  WSGIScriptAlias / /var/www/html/captive-portal/app.wsgi
  <Directory /var/www/html/captive-portal/corendon-captive-portal/>
    WSGIProcessGroup captive-portal-deamon
    WSGIApplicationGroup &{GLOBAL}
    Require all granted
  </Directory>
  WSGIDaemonProcess captive-portal-deamon user=www-data group=www-data threads=5
</VirtualHost>
EOF

# disabling default apache2 site and enabling flask site
sudo a2dissite 000-default
sudo a2ensite captive-portal

# WSGI config file
sudo cat > /var/www/html/captive-portal/app.wsgi << EOF
#!/usr/bin/python
import sys
sys.path.insert(0,"/var/www/html/captive-portal/corendon-captive-portal")

from __init__ import create_app
application = create_app()
EOF

sudo cat > /etc/sudoers.d/www-data << EOF
www-data ALL=NOPASSWD: /usr/sbin/ipset
EOF

# Setup database
sudo mysql < /var/www/html/captive-portal/corendon-captive-portal/database_setup.sql

# Install the npm pakages
sudo npm install --prefix /var/www/html/captive-portal/corendon-captive-portal

# Setup tailwindcss
npx tailwindcss -i /var/www/html/captive-portal/corendon-captive-portal/static/src/input.css -o /var/www/html/captive-portal/corendon-captive-portal/static/dist/css/output.css

# Reload apache2 to load the right config
sudo systemctl reload apache2
