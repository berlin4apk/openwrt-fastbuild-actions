#!/bin/bash

# set -eo pipefail
set -vx

echo "start ON HOST ###########################################"
####        realfs=$(df -x devtmpfs 2>/dev/null | tail -n +2 | awk '{print $6;}' | xargs  )
#        find "${realfs}" \( -iname "*ccache" \) -or  \( -iname "bc-*" \) -ls 2>&1 | grep -v "Permission denied"
#        find "${realfs}" -iname "*ccache" -o  -iname "bc-*"  -ls 2>&1 | grep -v "Permission denied"
###echo "${realfs}"
#        find "${realfs}" -iname '*ccache'  -iname 'bc-*'  -ls
# working #        find /  \( \( -iname "*ccache" \) -or  \( -iname "bc-*" \) \) -not  \( \( -iname "/dev" \) -or \( -iname "/sys" \) -or \( -iname "/proc" \) -or \( -iname "/foobla" \) \) -ls 2>&1 | grep -v "Permission denied"
 find /tmp /home / \( \( -iname "*ccache" \) -or  \( -iname "bc-*" \)  -or  \( -iname "openwrt" \) \) -not  \( \( -iname "/dev" \) -or \( -iname "/sys" \) -or \( -iname "/proc" \) -or \( -iname "/foobla" \) \) -ls 2>&1 | grep -v "Permission denied"
echo "end ON HOST ###########################################"


# shellcheck disable=SC1090
source "${HOST_WORK_DIR}/scripts/host/docker.sh"

echo "started=1" >> "$GITHUB_OUTPUT"
docker_exec -e MODE=m "${BUILDER_CONTAINER_ID}" "${BUILDER_WORK_DIR}/scripts/test-ccache-dir.sh"
echo "status=success" >> "$GITHUB_OUTPUT"
