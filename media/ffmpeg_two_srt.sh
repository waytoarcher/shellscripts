#!/usr/bin/env bash
#合并中英字幕到视频文件

input=$1
chsrt=$2
ensrt=$3
output=$4

ffmpeg -i "${input}" -i "${chsrt}" -i "${ensrt}" -map 0:v -map 0:a \
    -map 1 -map 2  -c:v copy -c:a copy -c:s mov_text -metadata:s:s:0 \
    language=chn -metadata:s:s:1 language=eng "${output}"
