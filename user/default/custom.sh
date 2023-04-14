#!/bin/bash

echo "= default custom.sh ==== $0 ==== start ==========================================="

for FILE in custom_*.sh; do
	set -vx
	#[ -e "$FILE" ] && . "$FILE"
	if [ -r $FILE ]; then
          bash "$FILE"
        fi
	
	set +vx
done
unset FILE

bash -xc "wc -l .config.diff"
bash -xc "wc -l .config"
for FILE in config_*.custom; do
	set -vx
	#[ -e "$FILE" ] && . "$FILE"
	#bash "$FILE"
	ls -la *config* *.config* 
	#mv .config .config.diff
	#cat .config.diff | tee -a .config
	cat "$FILE" | tee -a .config.diff
	set +vx
done
unset FILE
bash -xc "wc -l .config.diff"
bash -xc "wc -l .config"

set -vx
#mv .config .config.diff
#cp config_xiaomi_lumi .config
#cat .config.diff >> .config
### mv .config .config.diff
### cp config.custom .config
### cat .config.diff | tee -a .config
### #cat config.pre_custom | tee -a .config
set +vx

# rm ./package/feeds/packages/node
# rm ./package/feeds/packages/node-*
# ./scripts/feeds update node
# ./scripts/feeds install -a -p node
# make defconfig
echo "= default custom.sh ==== $0 ==== end ==========================================="
