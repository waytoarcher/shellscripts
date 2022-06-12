#!/bin/bash
#
# Copyright (C) 2021 Deepin Technology Co., Ltd.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#Name       :   uos-disable-package
#Desciption :   屏蔽安装指定软件包
#Time       :   2021-05-24
#Author     :   user
#Connect    :   user@uniontech.com

#只有root权限可运行此脚本
if ! [ "$(id -u)" -eq 0 ]; then
    echo "Please run $0 with root."
    exit 0
fi
out() { printf "%s %s\n%s\n" "$1" "$2" "${@:3}"; }
error() { out "==> ERROR:" "$@"; } >&2
warning() { out "==> WARNING:" "$@"; } >&2
msg() { out "==>" "$@"; }
function help() {
    msg "bash $0 enable/disable packagenames"
    exit 0
}
case $1 in
    -h | --help | -H | --HELP | help | h | H | HELP)
        help
        ;;
    *) ;;
esac

package_switch=${1}
shift 1
if [ 0 == "$#" ]; then
    help
    exit 1
fi
#屏蔽某软件包，建立.disable文件，优先级设定为-1
function disable_package() {
    packagenames=("$@")
    for packagename in ${packagenames[*]}; do
        if apt show "${packagename}" > /dev/null 2>&1; then
            cat >> /etc/apt/preferences.d/"${packagename}".disable << EOF
Package: ${packagename}
Pin: release *
Pin-Priority: -1
EOF
        else
            warning "No ${packagename} package."
            continue
        fi
    done
    echo "Now Disabled packages:"
    ls -1 /etc/apt/preferences.d/*.disable 2> /dev/null
}
#允许时，移除对应的disable文件
function enable_package() {
    packagenames=("$@")
    for packagename in ${packagenames[*]}; do
        rm -rf /etc/apt/preferences.d/"${packagename}".disable &> /dev/null
    done
    echo "Now Disabled packages:"
    ls -1 /etc/apt/preferences.d/*.disable 2> /dev/null
}
if [ enable == "$package_switch" ]; then
    apt update > /dev/null 2>&1
    enable_package "$@"
    apt update > /dev/null 2>&1
elif [ disable == "$package_switch" ]; then
    apt update > /dev/null 2>&1
    disable_package "$@"
    apt update > /dev/null 2>&1
else
    help
    exit 1
fi
