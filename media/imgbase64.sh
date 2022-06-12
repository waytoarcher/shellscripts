#!/bin/bash
cat << EOF|tee /tmp/image.md
![image][imagebase64]
[imagebase64]:data:image/jpg;base64,$(base64 -w 0 ${1})
EOF
