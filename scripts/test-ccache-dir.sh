#!/bin/bash

# set -eo pipefail

echo "start in DOCKER ###########################################"
        realfs=$(df -x devtmpfs | tail -n +2 | awk '{print $6;}' | xargs)
        find ${realfs} -iname "*ccache" -o -iname "bc-*" -ls 2>&1 | grep -v "Permission denied"
echo "end in DOCKER ###########################################"
