#!/bin/sh

if [ -r /bootmnt/env.sh ]; then
	source /bootmnt/env.sh
else
	BASE_URL="http://signage.rpi.edu"
fi

MAC=`ifconfig | perl -ne 'print $1 if /^eth0.*HWaddr (([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2})/'`

/usr/bin/xset s off
/usr/bin/xset -dpms
/usr/bin/xfwm4 &
/usr/bin/unclutter &
/usr/bin/midori --app "$BASE_URL/\?mac=$MAC" --execute Fullscreen

