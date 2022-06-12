#!/usr/bin/bash
#v1.0 by sandylaw <waytoarcher@gmail.com> 2020-09-20
yes | sudo pacman -Sy
sudo sed -ri '/archlinuxcn/d' /etc/pacman.conf || true
cat << EOF | sudo tee -a /etc/pacman.conf
[archlinuxcn]
Server = https://mirrors.ustc.edu.cn/archlinuxcn/\$arch
EOF
sudo pacman -Sy
sudo pacman -S archlinuxcn-keyring
yes | sudo pacman -S yay
yes | sudo pacman -S git mpv telegram-desktop proxychains privoxy

sudo sed '$d' /etc/proxychains.conf
cat << EOF | sudo tee -a /etc/proxychains.conf
socks5  192.168.122.233 1080
EOF
yay --noconfirm -S fcitx5 fcitx5-configtool fcitx5-qt fcitx5-gtk fcitx5-mozc fcitx5-chinese-addons
cat << EOF | tee ~/.pam_environment
INPUT_METHOD  DEFAULT=fcitx5
GTK_IM_MODULE DEFAULT=fcitx5
QT_IM_MODULE  DEFAULT=fcitx5
XMODIFIERS    DEFAULT=\@im=fcitx5
EOF
mkdir -p ~/.config/autostart
cp /usr/share/applications/fcitx5.desktop ~/.config/autostart/

if ! [ -f /usr/local/bin/dwm] || ! [ -f /usr/bin/dwm ];then
	wget -N --no-check-certificate -q -O install.sh "https://raw.githubusercontent.com/sandylaw/dwm/master/install.sh" && chmod +x install.sh && bash install.sh
fi
function install_oh_my_bash(){
bash -c "$(wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)"
}
install_oh_my_bash

yay --noconfirm -S bluez bluez-utils blueman pulseaudio-bluetooth
sleep 1
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service
sudo sed -ri '/^#AutoEnable=/cAutoEnable=true' /etc/bluetooth/main.conf
yay --noconfirm -S rdesktop xrdp zerotier-one 
sleep 1
sudo systemctl enable zerotier-one
sudo systemctl start zerotier-one
sleep 1
sudo zerotier-cli join 6ab565387a794cd9
yay --noconfirm -Rsc gnu-netcat || true
yay --noconfirm -S openbsd-netcat
yay --noconfirm -S ovmf libvirt virt-manager
sudo pacman -Syu --noconfirm ebtables dnsmasq
sudo systemctl enable libvirtd
sudo systemctl restart libvirtd
sudo virsh net-autostart default
yay -S --noconfirm --needed libguestfs

yay -S --noconfirm sof-firmware

cat <<EOF | sudo tee -a /etc/pulse/default.pa
load-module module-alsa-sink device=hw:0,0 channels=4
load-module module-alsa-source device=hw:0,6 channels=4
EOF
