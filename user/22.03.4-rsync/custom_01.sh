#!/bin/bash

echo "= $0 ==== start ==========================================="
# rm ./package/feeds/packages/node
# rm ./package/feeds/packages/node-*
# ./scripts/feeds update node
# ./scripts/feeds install -a -p node
# make defconfig

set -x
mkdir -p dl ## FIXME ##
mkdir -p /home/builder/dl  ## FIXME ##
mkdir -p /home/builder/openwrt/dl  ## FIXME ##

tree -a ./
echo "= $0 ==== end ==========================================="
