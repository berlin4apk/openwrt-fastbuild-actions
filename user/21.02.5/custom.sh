#!/bin/bash

echo "= $0 ==== start ==========================================="
bash -xc "wc -l .config.diff"
bash -xc "wc -l .config"
# rm ./package/feeds/packages/node
# rm ./package/feeds/packages/node-*
# ./scripts/feeds update node
# ./scripts/feeds install -a -p node
# make defconfig
echo "foo make defconfig"
bash -xc "wc -l .config.diff"
bash -xc "wc -l .config"
echo "= $0 ==== end ==========================================="
