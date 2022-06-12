#!/bin/bash
wget https://down.cloudorz.com/Router/LEDE/x86_64/Lean/openwrt-x86-64-generic-squashfs-combined.img.gz || exit 1
gunzip -dq openwrt-x86-64-generic-squashfs-combined.img.gz &>/dev/null
if ! [ -f openwrt-x86-64-generic-squashfs-combined.img ]; then
	exit 1
fi
qemu-img create -f qcow2 "$HOME"/Downloads/lede.qcow2 1G
sync
sleep 1
sudo dd if=openwrt-x86-64-generic-squashfs-combined.img of="$HOME"/Downloads/lede.qcow2
sync
sleep 1

virt-install --import -n LEDE --memory 512 --arch x86_64 --vcpus 1 \
	--disk "$HOME"/Downloads/lede.qcow2,device=disk,bus=virtio \
	--os-type=linux \
	--os-variant generic \
	--graphics spice \
	--noreboot \
	--connect qemu:///system \
	--network network:default \
	--check path_in_use=off
