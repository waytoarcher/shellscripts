#!/bin/bash
#我这里要切除的开头和结尾都是 7 秒
beg=7
end=7

#用 for 循环直接获取当前目录下的 mp4、mp3、avi 等文件循环处理，单个文件可以去掉 for 循环
for i in (*.mp4,*.mp3,*.avi ); do
	#将元数据信息临时保存到 tmp.log 文件中
    nohup /usr/local/ffmpeg/bin/ffmpeg -i "$i" > tmp.log
    #获取视频的时长，格式为  00:00:10,10 （时：分：秒，微妙）
    time="`cat /usr/local/ffmpeg/tmp.log |grep Duration: |awk  '{print $2}'|awk -F "," '{print $1}'|xargs`"
    echo $time
    #求视频的总时长，先分别求出小时、分、秒的值，这里不处理微秒，可以忽略
    hour="`echo $time |awk -F ":" '{print $1}' `"
    min="`echo $time |awk -F ":" '{print $2}' `"
    sec="`echo $time |awk -F ":" '{print $3}'|awk -F "." '{print $1}' `"
    #echo $hour $min $sec
    num1=`expr $hour \* 3600`
    num2=`expr $min \* 60`
    num3=$sec
    #计算出视频的总时长（秒）
    sum=`expr $num1 + $num2 + $num3`  
    
    #总时长减去开头和结尾就是截取后的视频时长,并且这里不需要再转回 hour:min:sec 的格式，直接使用结果即可
    newtime=`expr $sum - $beg - $end`
    echo $newtime
    /usr/local/ffmpeg/bin/ffmpeg -ss 00:00:07 -i $i -t $newtime -c:v copy -c:a copy /data/tmp/$i -y
done
