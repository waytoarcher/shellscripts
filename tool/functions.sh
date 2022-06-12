#!/bin/bash

out() { printf "%s %s\n%s\n" "$1" "$2" "${@:3}"; }
error() { out "==> ERROR:" "$@"; } >&2
warning() { out "==> WARNING:" "$@"; } >&2
msg() { out "==>" "$@"; }
msg2() { out "  ->" "$@"; }
die() {
	error "$@"
	exit 1
}

get_timer() {
	date +%s
}

# $1: start timer
elapsed_time() {
	echo "$1" "$(get_timer)" | awk '{ printf "%0.2f",($2-$1)/60 }'
}

show_elapsed_time() {
	msg "Time %s: %s minutes..." "$1" "$(elapsed_time "$2")"
}

ignore_error() {
	"$@" 2>/dev/null
	return 0
}
package() {
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
