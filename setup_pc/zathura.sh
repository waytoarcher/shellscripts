#!/usr/bin/env bash
# By Sandylaw <waytoarcher@gmail.com>
# Sat, 04 Sep 2021 06:29:55 PM +0800
set -euo pipefail

sudo apt install zathura -y
proxychains git clone https://github.com/dracula/zathura ~/.config/zathura/
