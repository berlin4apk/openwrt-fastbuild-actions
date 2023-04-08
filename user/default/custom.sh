#!/bin/bash

echo "= $0 ==== start ==========================================="

for FILE in custom_*.sh; do
	set -vx
	#[ -e "$FILE" ] && . "$FILE"
	bash "$FILE"
	set +vx
done
unset FILE

set -vx
#mv .config .config.diff
#cp config_xiaomi_lumi .config
#cat .config.diff >> .config
mv .config .config.diff
cp config.custom .config
cat .config.diff | tee -a .config
#cat config.pre_custom | tee -a .config
set +vx

# rm ./package/feeds/packages/node
# rm ./package/feeds/packages/node-*
# ./scripts/feeds update node
# ./scripts/feeds install -a -p node
# make defconfig
echo "= $0 ==== end ==========================================="
