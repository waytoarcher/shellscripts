#! /bin/bash
# 去重复行，只保留一行相同内容
trip() {
    keyword=$1
    file=$2
    keyword_wc=$(grep -rn "$keyword" "$file" | wc -l)
    while true; do
        if [ "$keyword_wc" -gt 1 ]; then
            sed -ri "0,/$keyword/{//d;}" "$file" &> /dev/null
            keyword_wc=$((keyword_wc - 1))
        else
            break
        fi
    done
}
#去重复关键字，只保留一个相同关键字
wtrip() {
    keyword=$1
    file=$2
    keyword_wc=$(grep -rn "$keyword" "$file" | wc -w)
    while true; do
        if [ "$keyword_wc" -gt 1 ]; then
            sed -ri "0,/$keyword/s///" "$file" &> /dev/null
            keyword_wc=$((keyword_wc - 1))
        else
            break
        fi
    done
}
