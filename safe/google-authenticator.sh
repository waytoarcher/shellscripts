#!/usr/bin/env bash
out() { printf "%s %s\n%s\n" "$1" "$2" "${@:3}"; }
error() { out "==> ERROR:" "$@"; } >&2
function google-authenticator() {
	if which google-authenticator >/dev/null 2>&1; then
		if [ ! -d "$HOME" ] || [ "/" == "$HOME" ]; then
			echo ""
			error "The user $USER has no home directory."
			error "Please contact the administrator."
		else
			/usr/bin/google-authenticator
		fi
	else
		error "Please install libpam-google-authenticator first."
	fi
}
