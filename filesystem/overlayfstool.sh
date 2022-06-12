#!/usr/bin/env bash
#
# overlayfstool
if ! [ "$(id -u)" -eq 0 ]; then
    echo "Please run $0 with root."
    exit 1
fi
if [[ $# -ne 1 ]]; then
    echo "Usage: $(basename "$0") enable/disable"
    exit 1
fi
if [[ "enable" != "$1" || "disable" != "$1" ]]; then
    echo "Usage: $(basename "$0") enable/disable"
    exit 1
fi
if df -Th | grep -q /overlay; then
    overlaystate="yes"
else
    overlaystate="no"
fi
if [[ "$overlaystate" == "no" ]] && ! [[ -x /sbin/overlayroot.sh ]]; then
    echo "Please make sure /sbin/overlayroot.sh is executable"
    exit 1
fi
if [[ "$overlaystate" == "no" ]] && [[ "enable" == "$1" ]]; then
    if ! grep -q "init=/sbin/overlayroot.sh" /etc/default/grub; then
        sed -ri 's#^GRUB_CMDLINE_LINUX="(.*)"$#GRUB_CMDLINE_LINUX="init=/sbin/overlayroot.sh \1"#' "/etc/default/grub"
        update-grub
    fi
    rm -f /.overlayfs_disable
fi
if [[ "$overlaystate" == "yes" ]] && [[ "enable" == "$1" ]]; then
    rm -f /lower/.overlayfs_disable
fi
if [[ "$overlaystate" == "yes" ]] && [[ "disable" == "$1" ]]; then
    mount -o remount,rw /lower
    touch /lower/.overlayfs_disable
fi
if [[ "$overlaystate" == "no" ]] && [[ "disable" == "$1" ]]; then
    touch /.overlayfs_disable
fi
