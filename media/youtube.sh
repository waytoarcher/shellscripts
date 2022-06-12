#!/usr/bin/env bash
# By Sandylaw <waytoarcher@gmail.com>
# Thu, 24 Dec 2020 09:17:27 PM +0800
LOGFILE="$PWD/$(date +"%Y-%m-%d-%H-%M-%S.%N").log"
exec 3>&1 4>&2 >>"$LOGFILE" 2>&1
youtube-dl --verbose --ignore-errors --no-continue --no-overwrites --keep-video --no-post-overwrites --download-archive archive.txt --write-description --write-info-json --write-annotations --write-thumbnail --all-subs --output "%(uploader)s (%(uploader_id)s)/%(id)s/%(title)s - %(upload_date)s.%(ext)s" -f bestvideo[ext=mp4]+bestaudio[ext=m4a] -- "$1"
