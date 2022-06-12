#!/bin/bash

# Description: Script to install and configure Samba in debian.
# Author: Gustavo Salazar L.
# Date: 2013-03-27
# modify by sandylaw
# Date: 2020-08-22
# How to use:
#   chmod +x samba-access.sh
#   ./smb.sh PATH_TO_SHARED_DIRECTORY  PERMISSIONS
#   or bash samba.sh
#
# $1 = path , e.g. /home/myuser/publicdir
# $2 = permissions  ,  e.g  777 755
#
if [ "$UID" == 0 ]; then
    echo "Please user non root run it."
    exit 1
fi
_me="$USER"
if [ -z "$1" ]; then
    echo "How to use this script?"
    echo "./samba-acess.sh  PATH_TO_SHARED_DIRECTORY  PERMISSIONS"
    Dir="$(zenity --title "Please select Shared Dir or file"  --file-selection --directory)" 2> /dev/null
elif [ -d "$1" ]; then
    Dir=$(realpath "$1")
fi

if [ -z "$Dir" ]; then
    echo "Please select a dir."
    exit 1
fi

if [ -z "$2" ]; then
    echo "Pass the persmissions of the directory you want to share as the second parameter."
    read -rp "E.g 777 or 755 or 764: " rwx
elif [ "$2" -le 777 ]; then
    rwx="$2"
fi

# Install Samba

samba_not_installed=$(dpkg -s samba 2>&1 | grep "not installed")
if [ -n "$samba_not_installed" ]; then
    echo "Installing Samba"
    sudo apt install samba -y
fi

# Configure directory that will be accessed with Samba
title=$(basename "$Dir")
sudo sed -ri "/$title/,+12d" /etc/samba/smb.conf
echo "
[$title]
comment = My Public Folder
path = $Dir
public = yes
writable = yes
create mast = 0$rwx
force user = $_me
force group = $_me
guest ok = yes


security = SHARE
" | sudo tee -a /etc/samba/smb.conf

# Restart Samba service

sudo /etc/init.d/smbd restart

# Give persmissions to shared directory

sudo chmod -R "$rwx" "$Dir"

# Message to the User
systemctl status smbd
echo  "To access the shared machine from Windows :"
echo "\\\\$(ifconfig virbr0 | grep inet | awk '{print $2}')"
echo "And then input you Host username $_me and passwd"
