#!/bin/bash
################################################################################
# Script for Installation: ODOO Community server on Ubuntu 16.04 (64 bits)
# Authors
#   * André Schenkels, ICTSTUDIO 2015
#   * Javi Melendez, <javimelex@gmail.com> 2016
#-------------------------------------------------------------------------------
#  
# This script will install ODOO Community Server on
# clean Ubuntu 16.04 Desktop (64 bits)
#-------------------------------------------------------------------------------
# USAGE:
#
# odoo-install
#
# EXAMPLE:
# chmod +x odoo-install.sh
# ./odoo-install.sh 
#
################################################################################
 
# Fixed parameters
# Odoo
OE_USER="odoo"
OE_HOME="/home/$OE_USER"
OE_HOME_EXT="/home/$OE_USER/git/odoo"

# Enter version for checkout "9.0", "8.0", "7.0", "master" for trunk
OE_VERSION="8.0"

# Set the superadmin password
OE_SUPERADMIN="admin"
OE_CONFIG="$OE_USER-server"
INIT_FILE=/lib/systemd/system/$OE_CONFIG.service

# Set locale
LOCALE_LANG=es_ES.UTF-8

#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n---- Update Server ----"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y locales

#--------------------------------------------------
# Install PostgreSQL Server
#--------------------------------------------------
sudo dpkg-reconfigure locales
sudo locale-gen $LOCALE_LANG
sudo /usr/sbin/update-locale LANG=$LOCALE_LANG

echo -e "\n---- Set locales ----"
sudo echo "LC_ALL=$LOCALE_LANG" >> /etc/environment

echo -e "\n---- Install PostgreSQL Server ----"
sudo apt-get install -y postgresql

echo -e "\n---- Creating the ODOO PostgreSQL User  ----"
sudo su - postgres -c "createuser -s $OE_USER" 2> /dev/null || true
sudo su - postgres -c "psql -c \"ALTER USER $OE_USER WITH ENCRYPTED PASSWORD '$OE_SUPERADMIN';\""

sudo systemctl restart postgresql.service
#--------------------------------------------------
# System Settings
#--------------------------------------------------

echo -e "\n---- Create ODOO system user ----"
sudo adduser --system --quiet --shell=/bin/bash --home=$OE_HOME --gecos 'ODOO' --group $OE_USER

echo -e "\n---- Create Log directory ----"
sudo mkdir /var/log/$OE_USER
sudo chown $OE_USER:$OE_USER /var/log/$OE_USER

#--------------------------------------------------
# Install Basic Dependencies
#--------------------------------------------------
echo -e "\n---- Install tool packages ----"
sudo apt-get install -y wget git python-pip python-imaging python-setuptools python-dev libxslt1-dev libxml2-dev libldap2-dev libsasl2-dev node-less postgresql-server-dev-all libjpeg-dev libfreetype6-dev zlib1g-dev libpng12-dev

echo -e "\n---- Install wkhtml and place on correct place for ODOO 8 ----"
sudo wget http://download.gna.org/wkhtmltopdf/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb
sudo dpkg -i wkhtmltox-0.12.1_linux-trusty-amd64.deb
sudo apt-get install -f -y
sudo dpkg -i wkhtmltox-0.12.1_linux-trusty-amd64.deb
sudo ln -s /usr/local/bin/wkhtmltopdf /usr/bin
sudo ln -s /usr/local/bin/wkhtmltoimage /usr/bin
sudo rm wkhtmltox-0.12.1_linux-trusty-amd64.deb

#--------------------------------------------------
# Install ODOO
#--------------------------------------------------

echo -e "\n==== Download ODOO Server ===="
cd $OE_HOME
sudo su $OE_USER -c "git clone --depth 1 --single-branch --branch $OE_VERSION https://github.com/odoo/odoo $OE_HOME_EXT/"
cd -

echo -e "\n---- Create custom module directory ----"
sudo su $OE_USER -c "mkdir -p $OE_HOME/custom/addons"

echo -e "\n---- Setting permissions on home folder ----"
sudo chown -R $OE_USER:$OE_USER $OE_HOME/*

#--------------------------------------------------
# Install Dependencies
#--------------------------------------------------
echo -e "\n---- Install python packages ----"
sudo pip install -r $OE_HOME_EXT/requirements.txt
sudo easy_install pyPdf vatnumber pydot psycogreen suds ofxparse

#--------------------------------------------------
# Configure ODOO
#--------------------------------------------------
echo -e "* Create server config file"
sudo cp $OE_HOME_EXT/debian/openerp-server.conf /etc/$OE_CONFIG.conf
sudo chown $OE_USER:$OE_USER /etc/$OE_CONFIG.conf
sudo chmod 640 /etc/$OE_CONFIG.conf

echo -e "* Change server config file"
echo -e "** Remove unwanted lines"
sudo sed -i "/db_user/d" /etc/$OE_CONFIG.conf
sudo sed -i "/admin_passwd/d" /etc/$OE_CONFIG.conf
sudo sed -i "/addons_path/d" /etc/$OE_CONFIG.conf

echo -e "** Add correct lines"
sudo su root -c "echo 'db_user = $OE_USER' >> /etc/$OE_CONFIG.conf"
sudo su root -c "echo 'admin_passwd = $OE_SUPERADMIN' >> /etc/$OE_CONFIG.conf"
sudo su root -c "echo 'logfile = /var/log/$OE_USER/$OE_CONFIG$1.log' >> /etc/$OE_CONFIG.conf"
sudo su root -c "echo 'addons_path = $OE_HOME/custom/addons,$OE_HOME_EXT/addons' >> /etc/$OE_CONFIG.conf"

echo -e "* Create startup file"
sudo su root -c "echo '#!/bin/sh' >> $OE_HOME/start.sh"
sudo su root -c "echo 'sudo -u $OE_USER $OE_HOME_EXT/openerp-server --config=/etc/$OE_CONFIG.conf' >> $OE_HOME/start.sh"
sudo chmod 755 $OE_HOME/start.sh

#--------------------------------------------------
# Adding ODOO as a deamon (initscript)
#--------------------------------------------------
sudo rm $INIT_FILE
sudo touch $INIT_FILE
sudo chmod 666 $INIT_FILE

echo -e "* Create systemd unit file"
sudo echo '[Unit]' >> $INIT_FILE
sudo echo 'Description=ODOO Application Server' >> $INIT_FILE
sudo echo 'Requires=postgresql.service' >> $INIT_FILE
sudo echo 'After=postgresql.service' >> $INIT_FILE
sudo echo '[Install]' >> $INIT_FILE
sudo echo "Alias=$OE_CONFIG.service" >> $INIT_FILE
sudo echo '[Service]' >> $INIT_FILE
sudo echo 'Type=simple' >> $INIT_FILE
sudo echo 'PermissionsStartOnly=true' >> $INIT_FILE
sudo echo "User=$OE_USER" >> $INIT_FILE
sudo echo "Group=$OE_USER" >> $INIT_FILE
sudo echo "SyslogIdentifier=$OE_CONFIG" >> $INIT_FILE
sudo echo "PIDFile=/run/odoo/$OE_CONFIG.pid" >> $INIT_FILE
sudo echo "ExecStartPre=/usr/bin/install -d -m755 -o $OE_USER -g $OE_USER /run/odoo" >> $INIT_FILE
sudo echo "ExecStart=$OE_HOME_EXT/openerp-server -c /etc/$OE_CONFIG.conf --pid=/run/odoo/$OE_CONFIG.pid --syslog $OPENERP_ARGS" >> $INIT_FILE
sudo echo 'ExecStop=/bin/kill $MAINPID' >> $INIT_FILE
sudo echo '[Install]' >> $INIT_FILE
sudo echo 'WantedBy=multi-user.target' >> $INIT_FILE

sudo chmod 644 $INIT_FILE

echo -e "* Enabling Systemd File"
sudo systemctl enable $INIT_FILE

echo -e "-- Starting ODOO Server --"
sudo systemctl start $OE_CONFIG.service


