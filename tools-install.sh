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
# LiClipse
LICLIPSE_PATH="/opt"
LICLIPSE_DESKTOP='liclipse.desktop'


#--------------------------------------------------
# Developer Tools
#--------------------------------------------------

echo -e "* Install gitg"
sudo apt-get install gitg -y

echo -e "* Install pgAdmin III"
sudo apt-get install pgadmin3 -y

echo -e "* Install LiClipse 3.0.3 (64 bits)"
sudo mkdir $LICLIPSE_PATH
sudo cd $LICLIPSE_PATH
sudo wget https://googledrive.com/host/0BwwQN8QrgsRpLVlDeHRNemw3S1E/LiClipse%203.0.3/liclipse_3.0.3_linux.gtk.x86_64.tar.gz
sudo tar xfz liclipse_3.0.3_linux.gtk.x86_64.tar.gz
sudo rm liclipse_3.0.3_linux.gtk.x86_64.tar.gz
sudo ln -s ./liclipse/LiClipse /usr/bin/liclipse
sudo cp ./liclipse/icon.xpm /usr/share/pixmaps/liclipse.xpm

sudo touch /usr/share/applications/$LICLIPSE_DESKTOP
sudo chmod 666 /usr/share/applications/$LICLIPSE_DESKTOP
sudo cat > /usr/share/applications/$LICLIPSE_DESKTOP <<EOL
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
EOL
sudo chmod 644 /usr/share/applications/$LICLIPSE_DESKTOP

# Method 1
oldlist=`sudo -u $OE_USER dbus-launch --exit-with-session gsettings get com.canonical.Unity.Launcher favorites`
newlist=`echo $oldlist | sed "s/]/, '${LICLIPSE_DESKTOP}']"/`
sudo -u $OE_USER dbus-launch --exit-with-session gsettings set com.canonical.Unity.Launcher favorites "$newlist"
# Method 2
sudo su $OE_USER
oldlist=`gsettings get com.canonical.Unity.Launcher favorites`
newlist=`echo $oldlist | sed "s/]/, '${LICLIPSE_DESKTOP}']"/`
gsettings set com.canonical.Unity.Launcher favorites "$newlist"
exit




