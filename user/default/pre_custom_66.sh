#!/bin/bash

### _install_if_not_has_command ccache

# curl -LORJ https://github.com/ccache/ccache/releases/download/v4.7.5/ccache-4.7.5-linux-x86_64.tar.xz.asc
# curl -LORJ https://github.com/ccache/ccache/releases/download/v4.7.5/ccache-4.7.5-linux-x86_64.tar.xz
# curl -LORJ https://github.com/ccache/ccache/releases/download/v4.8/ccache-4.8-linux-x86_64.tar.xz
# curl -LORJ https://github.com/ccache/ccache/releases/download/v4.8/ccache-4.8-linux-x86_64.tar.xz.asc
# curl -LORJ https://db.debian.org/fetchkey.cgi?fingerprint=5A939A71A46792CF57866A51996DDA075594ADB8
### curl -L https://github.com/ccache/ccache/releases/download/v4.8/ccache-4.8-linux-x86_64.tar.xz | sudo tar -xJvf- --strip-components=1 -C /usr/local/bin/
# curl -L https://github.com/ccache/ccache/releases/download/v4.8/ccache-4.8-linux-x86_64.tar.xz | sudo tar -xJvf- --strip-components=1 -C /usr/bin/
### FIXME ###
### sudo tar -xJvf ccache-4.8-linux-x86_64.tar.xz --strip-components=1 -C /usr/bin/


cat <<EOF | sudo tee /etc/ccache.conf-pre_custom_66 | sudo tee /usr/local/etc/ccache.conf-pre_custom_66
#cache_dir=/ccache/
cache_dir=/dev/shm/ccache/
#cache_dir=/tmp/ccache/
#temporary_dir /run/user/<UID>/ccache-tmp
### In previous versions of ccache, CCACHE_TEMPDIR had to be on the same filesystem as the CCACHE_DIR path, but this requirement has been relaxed.
# temporary_dir /run/user/$(id -u)/ccache-tmp # $XDG_RUNTIME_DIR The default is $XDG_RUNTIME_DIR/ccache-tmp (typically /run/user/<UID>/ccache-tmp) if XDG_RUNTIME_DIR is set and the directory exists, otherwise <cache_dir>/tmp. 
#compression=false
#compression_level
#file_clone=true
hard_link=false
umask=002
#secondary_storage="http://172.17.0.1:8080|layout=bazel"
#secondary_storage="file://home/builder/.ccache"
remote_storage="file:/home/builder/.ccache|file:/home/builder/openwrt/.ccache|file:/home/builder/ccache|file:/home/builder/openwrt/ccache"
max_size=1500M
# reshare (CCACHE_RESHARE or CCACHE_NORESHARE, see Boolean values above)
# If true, ccache will write results to secondary storage even for primary storage cache hits. The default is false.
# reshare=true
EOF

# Prepend ccache into the PATH
# echo 'export PATH="/usr/lib/ccache:$PATH"' | tee -a ~/.bashrc
echo 'export PATH="/usr/local/lib/ccache:/usr/lib/ccache:$PATH"' | tee -a ~/.bashrc
echo 'export CONFIG_CCACHE=y' | tee -a ~/.bashrc
# Source bashrc to test the new PATH
source ~/.bashrc && echo $PATH

# https://github.com/ccache/ccache/blob/master/test/suites/remote_file.bash
touch test.h
echo '#include "test.h"' >test.c
backdate test.h ||:
#$CCACHE_COMPILE -c test.c
ccache -vs
gcc -c test.c
ccache -vs


export CONFIG_CCACHE=y
ccache -V
ccache -p
ccache -svvv
## CONFIG_CCACHE=y make tools/ccache/compile


