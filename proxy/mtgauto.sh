#!/usr/bin/bash

while true; do
	nohup /usr/local/bin/mtg run -b 0.0.0.0:39665 --cloak-port=39665 ee7b624f4c6843d0ae8cb65cd2df82809d7761792e76326c6573732e636f6d >/tmp/mtg.log 2>&1 &
	sleep 1000
	killall mtg
	sleep 2
done
