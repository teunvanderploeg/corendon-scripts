# Install apache2, wsgi, pip3 mysql-server and git
sudo apt-get install apache2 libapache2-mod-wsgi-py3 python3-pip git mysql-server python3-virtualenv libmysqlclient-dev -y
# enable apache2 module wsgi
sudo a2enmod wsgi
# Set Python3 as default Python
sudo ln -sf /usr/bin/python3 /usr/bin/python

# Start mysql server
sudo systemctl start mysql.service

# Get git corendon-captive-portal repository and move to correct directory
sudo git clone https://github.com/teunvanderploeg/corendon-captive-portal.git /var/www/html/corendon-captive-portal

# Create virtual environment
sudo virtualenv /var/www/html/corendon-captive-portal venv
# Activate virtual environment
sudo ./var/www/html/corendon-captive-portal/venv/bin/activate
# Installing flask module in venv
sudo /var/www/html/corendon-captive-portal/venv/bin/pip3 install -r /var/www/html/corendon-captive-portal/requirements.txt

# Apache2 config for wsgi and flask site
sudo cat >> /etc/apache2/sites-available/captive-portal.conf << EOF
<VirtualHost *:80>
  ServerName yourdomain.com
  ServerAdmin youemail@email.com
  WSGIScriptAlias / /var/www/html/app.wsgi
  <Directory /var/www/html/corendon-captive-portal/>
    WSGIProcessGroup captive-portal-deamon
    WSGIApplicationGroup &{GLOBAL}
    Require all granted
  </Directory>
  WSGIDaemonProcess captive-portal-deamon user=odroid group=www-data threads=5
</VirtualHost>
EOF

# disabling default apache2 site and enabling flask site
sudo a2dissite 000-default
sudo a2ensite captive-portal

# WSGI config file
sudo cat >> /var/www/html/app.wsgi << EOF
#!/usr/bin/python
import sys

sys.path.insert(0,"/var/www/html/captive-portal")
from app import app as application
EOF

# Setup database
sudo mysql < /var/www/html/corendon-captive-portal/database_setup.sql

# Reload apache2 to load the right config
sudo systemctl reload apache2
