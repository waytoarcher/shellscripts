#!/bin/bash
NAME=screencast-$(date +%Y%m%d%H%M)
FPS=10
RESOLUTION=$(xdpyinfo | grep 'dimensions:'|awk '{print $2}')
cpu_nums=$(cat /proc/cpuinfo |grep processor|wc -l)
THREADS=$((cpu_nums/2))

echo Get prepared!
sleep 1
echo Starting up in $RESOLUTION - hit "q" to stop
ffmpeg -y -f alsa -ac 2 -i pulse -f x11grab -r $FPS -s $RESOLUTION -i :0.0 -acodec pcm_s16le $NAME-temp.wav -an -vcodec libx264 -preset ultrafast -threads 0 $NAME-temp.mp4 && \
echo Encoding to webm for YouTube, hold on && \
ffmpeg -i $NAME-temp.mp4 -i $NAME-temp.wav -threads $THREADS ~/Videos/$NAME.webm
rm -f $NAME-temp.mp4 $NAME-temp.wav
