#!/bin/bash -x
TOKEN="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"
while read -r r;do curl -XDELETE -H "Authorization: token $TOKEN" -H "Content-Type: application/json" "https://api.github.com/repos/$r";done < repos.txt
