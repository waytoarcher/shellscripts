#!/bin/bash
if [ -f /tmp/check_failed ]; then
    rm -f /tmp/check_failed &> /dev/null || exit
fi
if [ -f ./md5sum.txt ]; then
    sed -ri '/^$/d' ./md5sum.txt &> /dev/null
else
    exit 1
fi
declare -i PERCENT=0
file_total=$(find . -type f | grep -cv 'md5sum.txt\|isolinux/')
export file_total
(   
    num=0
    while read -r line; do
        if [ $PERCENT -le 100 ]; then
            md5=$(md5sum "${line##* }")
            if [ "${md5%% *}" = "${line%% *}" ]; then
                echo "XXX"
                echo "check ${line##* }..."
                echo "XXX"
            else
                echo "XXX"
                echo "check ${line##* } error!" > /tmp/check_failed
                echo "XXX"
                break
            fi
            echo $PERCENT
        fi
        num=$((num + 1))
        PERCENT=$(echo "scale=0;${num}*100/${file_total}" | bc)
    done < ./md5sum.txt

) | dialog --title "check md5..." --gauge "starting to check md5..." 6 100 0
sleep 1
if [ -f /tmp/check_failed ]; then
    value=$(cat /tmp/check_failed)
    dialog --title "check md5" --msgbox "checksum failed \n  $value " 10 60
else
    dialog --title "check md5" --msgbox "checksum success" 10 20
fi
clear
