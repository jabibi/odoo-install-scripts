#!/bin/bash
################################################################################
# Script for Installation: ODOO Developer Tools on Ubuntu 16.04 (64 bits)
# Authors
#   * Javi Melendez, <javimelex@gmail.com> 2016
#-------------------------------------------------------------------------------
#  
# This script will install ODOO Developer Tools on
# clean Ubuntu 16.04 Desktop (64 bits):
#   * gitg
#   * pgAdmin III
#   * PyCharm Community 2016.1.4
#   * LiClipse 3.0.3
#
#-------------------------------------------------------------------------------
# USAGE:
#
# tools-install
#
# EXAMPLE:
# chmod +x tools-install.sh
# ./tools-install.sh 
#
################################################################################
 
# Fixed parameters
OE_USER="odoo"

# PyCharm
PYCHARM_PATH=/opt

# LiClipse
LICLIPSE_PATH=/opt
LICLIPSE_DESKTOP='liclipse.desktop'
LICLIPSE_DESKTOP_PATH=/usr/share/applications/$LICLIPSE_DESKTOP

#--------------------------------------------------
# Install gitg
#--------------------------------------------------

echo -e "\n==== Install gitg ====\n"
sudo apt-get install gitg -y

#--------------------------------------------------
# Install pgAdmin III
#--------------------------------------------------

echo -e "\n==== Install pgAdmin III ====\n"
sudo apt-get install pgadmin3 -y

#--------------------------------------------------
# Install PyCharm 2016.1.4
#--------------------------------------------------

echo -e "\n==== Install PyCharm Community 2016.1.4 ====\n"
sudo mkdir -p $PYCHARM_PATH
cd $PYCHARM_PATH
sudo wget https://download.jetbrains.com/python/pycharm-community-2016.1.4.tar.gz
sudo tar xfz pycharm-community-2016.1.4.tar.gz
sudo rm pycharm-community-2016.1.4.tar.gz
cd -

#--------------------------------------------------
# Install LiClipse 3.0.3 (64 bits)
#--------------------------------------------------

echo -e "\n==== Install LiClipse 3.0.3 (64 bits) ====\n"
sudo mkdir -p $LICLIPSE_PATH
cd $LICLIPSE_PATH
sudo wget https://googledrive.com/host/0BwwQN8QrgsRpLVlDeHRNemw3S1E/LiClipse%203.0.3/liclipse_3.0.3_linux.gtk.x86_64.tar.gz
sudo tar xfz liclipse_3.0.3_linux.gtk.x86_64.tar.gz
sudo rm liclipse_3.0.3_linux.gtk.x86_64.tar.gz
sudo ln -sf $LICLIPSE_PATH/liclipse/LiClipse /usr/bin/liclipse
sudo cp ./liclipse/icon.xpm /usr/share/pixmaps/liclipse.xpm
cd -

sudo rm -f $LICLIPSE_DESKTOP_PATH
sudo touch $LICLIPSE_DESKTOP_PATH
sudo chmod 644 $LICLIPSE_DESKTOP_PATH
sudo su root -c "cat > $LICLIPSE_DESKTOP_PATH <<EOL
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Type=Application
Name=PyDev - LiClipse 
Icon=liclipse
Path=${LICLIPSE_PATH}/liclipse
Exec=${LICLIPSE_PATH}/liclipse/jre/bin/java -Xms40m -Xmx512m -Declipse.p2.unsignedPolicy=allow -Declipse.log.size.max=10000 -Declipse.log.backup.max=5 -Dpydev.funding.hide=1 -Dliclipsetext.funding.hide=1 -Dfile.encoding=UTF-8 -Djava.awt.headless=true -jar ${LICLIPSE_PATH}/liclipse//plugins/org.eclipse.equinox.launcher_1.3.200.v20160318-1642.jar -os linux -ws gtk -arch x86_64 -showsplash -launcher ${LICLIPSE_PATH}/liclipse/LiClipse -name LiClipse --launcher.library ${LICLIPSE_PATH}/liclipse//plugins/org.eclipse.equinox.launcher.gtk.linux.x86_64_1.1.400.v20160504-1419/eclipse_1616.so -startup ${LICLIPSE_PATH}/liclipse//plugins/org.eclipse.equinox.launcher_1.3.200.v20160318-1642.jar --launcher.overrideVmargs -exitdata 33800f -vm ${LICLIPSE_PATH}/liclipse/jre/bin/java -vmargs -Xms40m -Xmx512m -Declipse.p2.unsignedPolicy=allow -Declipse.log.size.max=10000 -Declipse.log.backup.max=5 -Dpydev.funding.hide=1 -Dliclipsetext.funding.hide=1 -Dfile.encoding=UTF-8 -Djava.awt.headless=true -jar ${LICLIPSE_PATH}/liclipse//plugins/org.eclipse.equinox.launcher_1.3.200.v20160318-1642.jar
StartupNotify=false
StartupWMClass=LiClipse
OnlyShowIn=Unity;
X-UnityGenerated=true
EOL"
