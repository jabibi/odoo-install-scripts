
#!/bin/bash
################################################################################
# Script for installing PyCharm on Ubuntu 16.04 (64 bits)
# Authors
#   * Javi Melendez, <javimelex@gmail.com> 2016
#-------------------------------------------------------------------------------
# USAGE:
#
# pycharm-umake
#
# EXAMPLE:
# chmod +x pycharm-umake.sh
# ./pycharm-umake.sh 
#
################################################################################

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# If PostgreSQL PPA has been added
cat << EOF > /etc/apt/preferences.d/pgdg.pref
Package: *
Pin: release o=apt.postgresql.org
Pin-Priority: 500

Package:  python*
Pin: release o=apt.postgresql.org
Pin-Priority: 400
EOF

# Install latest stable version of ubuntu-make
sudo add-apt-repository ppa:ubuntu-desktop/ubuntu-make
sudo apt-get update
sudo apt-get --reinstall install ubuntu-make

# Install PyCharm Community Edition
umake ide pycharm
# or Professional Edition
#umake ide pycharm-professional

# DONE

# To remove PyCharm installed via umake
#umake -r ide pycharm
# or
#umake -r ide pycharm-professional
