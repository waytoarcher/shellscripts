#!/bin/bash
exec 1>>/var/tmp/mirror-ib.log 2>&1
date
pushd /home/sandy/Downloads/shgit/ib.git > /dev/null || exit
git fetch origin
git push ib-sh --all
popd > /dev/null || exit
