#!/bin/bash

echo "= default pre_custom_00.sh ==== $0 ==== start ==========================================="

# ccache --set-config remote_storage="file:/${HOST_CCACHE_DIR}|file:/${BUILDER_CCACHE_DIR}"
# ${{ env.HOST_CCACHE_DIR }#{ env.BUILDER_CCACHE_DIR }}"

find -ls

echo "CONFIG_CCACHE=y" | tee -a config_000.diff

# CONFIG_CCACHE_DIR="/home/builder/.ccache"
#CONFIG_CCACHE_DIR="/dev/shm/$(id -u)/ccache/"
# CONFIG_CCACHE_DIR="/dev/shm/1001/ccache/"

echo "BUILDER_CCACHE_DIR ${BUILDER_CCACHE_DIR}"
echo "CONFIG_CCACHE_DIR=${BUILDER_CCACHE_DIR}/" | tee -a config_001.diff

# CONFIG_DOWNLOAD_FOLDER="/tmp/DLccache"
#CONFIG_DOWNLOAD_FOLDER="/dev/shm/$(id -u)/DLccache"
# CONFIG_DOWNLOAD_FOLDER="/dev/shm/1001/DLccache"
# CONFIG_DOWNLOAD_FOLDER="${BUILDER_DLCCACHE_DIR}/"

echo "BUILDER_DLCCACHE_DIR ${BUILDER_DLCCACHE_DIR}"

echo "CONFIG_DOWNLOAD_FOLDER=${BUILDER_DLCCACHE_DIR}/" | tee -a config_002.diff

echo "# DL_DIR=${BUILDER_DLCCACHE_DIR}/" | tee -a config_003.diff



echo "= default pre_custom_00.sh ==== $0 ==== end ==========================================="
find -ls
