#!/usr/bin/env bash
# By Sandylaw <waytoarcher@gmail.com>
# Thu, 24 Dec 2020 09:17:27 PM +0800
youtube-dl -ci -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]" --write-sub --embed-subs --merge-output-format mp4 "$1"
