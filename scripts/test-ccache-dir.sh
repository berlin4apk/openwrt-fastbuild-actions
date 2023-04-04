#!/bin/bash

# set -eo pipefail

echo "start in DOCKER ###########################################"
#        realfs=$(df -x devtmpfs | tail -n +2 | awk '{print $6;}' | xargs)
#        find ${realfs} -iname "*ccache" -o -iname "bc-*" -ls 2>&1 | grep -v "Permission denied"
 find /tmp /home / \( \( -iname "*ccache" \) -or  \( -iname "bc-*" \)  -or  \( -iname "openwrt" \) \) -not  \( \( -iname "/dev" \) -or \( -iname "/sys" \) -or \( -iname "/proc" \) -or \( -iname "/foobla" \) \) -ls 2>&1 | grep -v "Permission denied"
echo "end in DOCKER ###########################################"
