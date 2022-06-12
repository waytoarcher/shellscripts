#!/bin/bash
file=$1
perl -i -pe 's/\e[\[\(][0-9;]*[mGKFB]//g' "$file"
sed -ri 's/\r$//' "$file"
sed -ri 's/^\r//' "$file"
sed -ri 's/[ \t]*$//' "$file"
