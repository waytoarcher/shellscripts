#!/bin/bash
# setup vsftp for repo.
# by user <user@uniontech.com> 2020-11-18
set -x
function package() {
    packages=("$@")
    apt=$(command -v apt-get)
    yum=$(command -v yum)
    yay=$(command -v yay)
    if [ -z "$yay" ]; then
        pacman=$(command -v pacman)
    fi
    if [ -n "$apt" ]; then
        sudo apt-get update
        sudo apt-get -y install "${packages[@]}"
    elif [ -n "$yum" ]; then
        sudo yum -y install "${packages[@]}"
    elif [ -n "$yay" ]; then
        yay -S "${packages[@]}"
    elif [ -n "$pacman" ]; then
        sudo pacman -S "${packages[@]}"
    else
        echo "Err: no path to apt-get or yum" >&2
    fi
}

if ! vsftpdwho &> /dev/null; then
        package vsftpd
fi
vsftp_anon(){
sudo sed -ri '/anonymous_enable/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/no_anon_password/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/write_enable/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/anon_upload_enable/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/anon_mkdir_write_enable/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/anon_umask/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/anon_root/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/anon_other_write_enable/d' /etc/vsftpd.conf &> /dev/null
sudo sed -ri "/listen_ipv6/aanonymous_enable=YES\nno_anon_password=YES\nanon_root=/srv/ftp/\nwrite_enable=YES\nanon_upload_enable=YES\nanon_other_write_enable=YES\nanon_mkdir_write_enable=YES\nanon_umask=022" /etc/vsftpd.conf &> /dev/null
sudo sed -ri '/utf8_filesystem/cutf8_filesystem=YES' /etc/vsftpd.conf &> /dev/null
sudo chmod 755 /srv/ftp
sudo mkdir -p /srv/ftp/uploads
sudo chown ftp:ftp /srv/ftp/uploads
sudo chmod a+rwx /srv/ftp/uploads
sudo systemctl restart vsftpd.service
}
vsftp_anon
