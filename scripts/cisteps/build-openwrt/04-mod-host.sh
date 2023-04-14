#!/bin/bash

set -eo pipefail

# shellcheck disable=SC1090
#### source "${HOST_WORK_DIR}/scripts/host/docker.sh"
#### configure_docker
#### login_to_registry

echo "= 04-mod-host.sh ==== $0 ==== start ==========================================="


set -vx 
_has_command() {
    #command -v -- "$1" 2>/dev/null || hash -- "$1" 2>/dev/null
    hash -- "$1" 2>/dev/null
}

_install_command() {
export DEBIAN_FRONTEND=noninteractive
#    sudo -E apt-get -qq install --no-upgrade "$1" || $(sudo -E apt-get -qq update && sudo -E apt-get -qq install --no-upgrade "$1")
    sudo -E apt-get --yes install --no-upgrade "$1" ||:
    if _has_command "$1"; then
         echo "system has now command $1"
    else
         echo "system has still NOT command $1"
         sudo -E apt-get -qq --yes update
         sudo -E apt-get --yes install --no-upgrade "$1"
    fi
}

_install_if_not_has_command() {
    if _has_command "$1"; then
         echo "system has command $1"
    else
         echo "system has NOT command $1"
         echo "installing command $1"
        _install_command "$1"
    fi
}

_install_apt_deb() {
export DEBIAN_FRONTEND=noninteractive
#    sudo -E apt-get -qq install --no-upgrade "$1" || $(sudo -E apt-get -qq update && sudo -E apt-get -qq install --no-upgrade "$1")
    sudo -E apt-get --yes install --no-upgrade "$1" ||:
    if [ "x0" = "x$?" ] ; then
         sudo -E apt-get -qq --yes update
         sudo -E apt-get --yes install --no-upgrade "$1"
    fi
}

### _install_if_not_has_command genisoimage
_install_if_not_has_command tree
#_install_if_not_has_command foofeeoo
#
# _install_if_not_has_command redis-cli
# _install_if_not_has_command python3-redis
# _install_if_not_has_command python3-progress
# _install_if_not_has_command python3-progressbar
# _install_if_not_has_command python3-humanize

#_install_apt_deb redis-cli python3-redis python3-progress python3-progressbar python3-humanize
_install_apt_deb redis-tools
_install_apt_deb python3-redis 
_install_apt_deb python3-progress 
_install_apt_deb python3-progressbar 
_install_apt_deb python3-humanize


wget -O ccache-download-redis https://github.com/ccache/ccache/raw/v4.8/misc/download-redis
wget -O ccache-upload-redis https://github.com/ccache/ccache/raw/v4.8/misc/upload-redis

echo "eda111306e3d65ac61a86811596d18c283711f00bb5cd76d23df1f4b885d812a *ccache-download-redis" | sha256sum -c -
echo "5305b25e1534601fd102f295a40f5b670dfd63b5f525cd6079d0c5ac86a46c3c *ccache-upload-redis" | sha256sum -c -

sudo chmod 755 ccache-upload-redis ccache-download-redis
sudo cp -p ccache-upload-redis ccache-download-redis /usr/local/bin/

export REDIS_CONF=redis-y9g98g58d
export REDIS_USERNAME=
export REDIS_PASSWORD=

ccache -p
ccache --set-config remote_storage="redis://172.17.0.1|redis://172.18.0.1|redis://host.docker.internal|redis://redis-y9g98g58d"
ccache --set-config reshare=true
ccache --set-config remote_only=true
ccache -p



echo "= UIDs on Host ==== $0 ==============================================="
	set -vx
id -u
id -g
id
	set +vx
echo "= UIDs on Host ==== $0 ==============================================="

for FILE in mod-host_*.sh; do
	set -vx
	#[ -e "$FILE" ] && . "$FILE"
	bash "$FILE"
	set +vx
done
unset FILE

echo "= 04-mod-host.sh ==== $0 ==== end ==========================================="
