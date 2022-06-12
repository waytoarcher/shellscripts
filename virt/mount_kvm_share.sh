#!/usr/bin/env bash
part=$1
if [ -n "$part" ]; then
	mkdir -p "$HOME/$part"
	sudo mount -t 9p -o rw,trans=virtio "$part" "$HOME/$part" -oversion=9p2000.L,posixacl,cache=loose
else
	echo "Please set part name"
fi
