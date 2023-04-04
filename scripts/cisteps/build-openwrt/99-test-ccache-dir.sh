#!/bin/bash

# set -eo pipefail

echo "start ON HOST ###########################################"
        realfs=$(df -x devtmpfs | tail -n +2 | awk '{print $6;}' | xargs)
        find ${realfs} -iname "*ccache" -o -iname "bc-*" -ls 2>&1 | grep -v "Permission denied"
echo "end ON HOST ###########################################"


# shellcheck disable=SC1090
source "${HOST_WORK_DIR}/scripts/host/docker.sh"

echo "started=1" >> $GITHUB_OUTPUT
docker_exec -e MODE=m "${BUILDER_CONTAINER_ID}" "${BUILDER_WORK_DIR}/scripts/test-ccache-dir.sh"
echo "status=success" >> $GITHUB_OUTPUT
