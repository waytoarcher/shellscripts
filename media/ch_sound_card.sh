#!/bin/bash

CURRENT_PROFILE=$(pacmd list-cards | grep "active profile" | cut -d ' ' -f 3-)

if [ "$CURRENT_PROFILE" = "<output:hdmi-stereo>" ]; then
        pacmd set-card-profile 0 "output:analog-stereo+input:analog-stereo"
        disper -s
else 
        pacmd set-card-profile 0 "output:hdmi-stereo"
        disper -S        
fi

