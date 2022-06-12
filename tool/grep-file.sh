#!/usr/bin/bash
if_file=$1
source_file=$2
result_file=$3
while IFS= read -r line
do
line=$(echo $line |tr 'A-Z' 'a-z')
 if grep -q $line $source_file;then 
     grep /$line/ $source_file | tee -a $result_file
 else
     echo $line >> $result_file
 fi
done < $if_file
