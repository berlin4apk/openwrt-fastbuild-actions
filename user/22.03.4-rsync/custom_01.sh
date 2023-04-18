#!/bin/bash

echo "= $0 ==== start ==========================================="
# rm ./package/feeds/packages/node
# rm ./package/feeds/packages/node-*
# ./scripts/feeds update node
# ./scripts/feeds install -a -p node
# make defconfig

set -x

ls -la ./

echo "CONFIG_CCACHE=y" | tee -a config_010.diff
echo "BUILDER_CCACHE_DIR ${BUILDER_CCACHE_DIR}"
echo "CONFIG_CCACHE_DIR=${BUILDER_CCACHE_DIR}/" | tee -a config_011.diff
echo "BUILDER_DLCCACHE_DIR ${BUILDER_DLCCACHE_DIR}"
echo "CONFIG_DOWNLOAD_FOLDER=${BUILDER_DLCCACHE_DIR}/" | tee -a config_012.diff
echo "# DL_DIR=${BUILDER_DLCCACHE_DIR}/" | tee -a config_013.diff

echo "CONFIG_CCACHE=y" | tee -a .config
echo "CONFIG_CCACHE_DIR=${BUILDER_CCACHE_DIR}/" | tee -a .config
echo "CONFIG_DOWNLOAD_FOLDER=${BUILDER_DLCCACHE_DIR}/" | tee -a .config
echo "# DL_DIR=${BUILDER_DLCCACHE_DIR}/" | tee -a .config

cat .config



#mkdir -p dl ## FIXME ##
#mkdir -p /home/builder/dl  ## FIXME ##
#mkdir -p /home/builder/openwrt/dl  ## FIXME ##

tree -a ./
echo "= $0 ==== end ==========================================="
