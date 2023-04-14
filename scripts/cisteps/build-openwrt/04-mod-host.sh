#!/bin/bash

set -eo pipefail

# shellcheck disable=SC1090
#### source "${HOST_WORK_DIR}/scripts/host/docker.sh"
#### configure_docker
#### login_to_registry

echo "= 04-mod-host.sh ==== $0 ==== start ==========================================="

set -vx 
_has_command2() {
    command -v -- "$1" 2>/dev/null || hash -- "$1" 2>/dev/null
    #hash -- "$1" 2>/dev/null
}

_has_command() {
  # well, this is exactly `for cmd in "$@"; do`
  for cmd do
    command -v "$cmd" >/dev/null 2>&1 || return 1
  done
}

     _has_command sudo && {
    sudo -n echo 2>/dev/null && SudoVAR="-n $SudoVAR" || SudoVAR="$SudoVAR"
  }
     _has_command sudo && {
    sudo -E echo 2>/dev/null && export SudoE="sudo -E $SudoVAR" || SudoVAR="$SudoVAR"
  }
     _has_command sudo && {
    sudo echo 2>/dev/null && export Sudo="sudo $SudoVAR" || export Sudo=""
  }
  
docker_build_alpine_image() {
cat <<EOF | docker build --tag alpine -
FROM alpine:latest
RUN set -vx && apk add --no-cache redis bind-tools musl-utils iproute2
EOF
}
docker_build_alpine_image

docker_redis_ip_test() {
cat <<EOF | docker run --rm -i --add-host=host.docker.internal:host-gateway --name redis_alpine alpine:latest sh
set -vx
apk add --no-cache redis >/dev/null
serverlist="
redis://172.17.0.1
redis://172.18.0.1
redis://host.docker.internal
redis://host-gateway
redis://redis-y9g98g58d
redis://redis-2y9g98g58d
redis://redis
redis://redis-host
redis://redis-server
redis://localhost
redis://gateway.docker.internal
redis://docker.for.mac.host.internal
redis://docker.for.mac.localhost
redis://docker.for.win.host.internal
redis://docker.for.win.localhost
"
for t in \$serverlist; do redis-cli -u \$t   ping ||: ; done
EOF
}

docker_redis_ip_test_port_26379() {
cat <<EOF | docker run --rm -i --add-host=host.docker.internal:host-gateway --name redis_alpine alpine:latest sh
set -vx
apk add --no-cache redis >/dev/null
PORT=:26379
serverlist="
redis://172.17.0.1\$PORT
redis://172.18.0.1\$PORT
redis://host.docker.internal\$PORT
redis://host-gateway\$PORT
redis://redis-y9g98g58d\$PORT
redis://redis-2y9g98g58d\$PORT
redis://redis\$PORT
redis://redis-host\$PORT
redis://redis-server\$PORT
redis://localhost\$PORT
redis://gateway.docker.internal\$PORT
redis://docker.for.mac.host.internal\$PORT
redis://docker.for.mac.localhost\$PORT
redis://docker.for.win.host.internal\$PORT
redis://docker.for.win.localhost\$PORT
"
for t in \$serverlist; do redis-cli -u \$t   ping ||: ; done
EOF
}

# https://github.com/kraj/uclibc-ng/blob/master/extra/scripts/getent
docker_redis_ip2_test() {
cat <<EOF | docker run --rm -i --add-host=host.docker.internal:host-gateway --name redis_alpine alpine:latest sh
set -vx
apk add --no-cache bind-tools >/dev/null
serverlist="
172.17.0.1
172.18.0.1
host.docker.internal
host-gateway
redis-y9g98g58d
redis-2y9g98g58d
redis
redis-host
redis-server
localhost
gateway.docker.internal
docker.for.mac.host.internal
docker.for.mac.localhost
docker.for.win.host.internal
docker.for.win.localhost
"
for t in \$serverlist; do dig +short \$t | grep -E '^[0-9.]+$' | head -n 1 ; done
EOF
}

docker_redis_ip3_test() {
cat <<EOF | docker run --rm -i --add-host=host.docker.internal:host-gateway --name redis_alpine alpine:latest sh
set -vx
apk add --no-cache musl-utils >/dev/null
serverlist="
172.17.0.1
172.18.0.1
host.docker.internal
host-gateway
redis-y9g98g58d
redis-2y9g98g58d
redis
redis-host
redis-server
localhost
gateway.docker.internal
docker.for.mac.host.internal
docker.for.mac.localhost
docker.for.win.host.internal
docker.for.win.localhost
"
for t in \$serverlist; do getent ahosts \$t ; done
EOF
}

docker_alpine_ip() {
cat <<EOF | docker run --rm -i alpine:latest sh
apk add --no-cache iproute2 >/dev/null
ip -4 route show default | cut -d' ' -f3
EOF
}

docker_ip_fn2() {
cat <<EOF | docker run --rm -i busybox:latest sh
ip -4 route show default | cut -d' ' -f3
EOF
}

docker_ip_fn3() {
cat <<EOF | docker run --rm -i --add-host=host.docker.internal:host-gateway busybox:latest sh
hostname -i host.docker.internal
EOF
}

docker_ip_fn4() {
cat <<EOF | docker run --rm -i --add-host=host.docker.internal:host-gateway busybox:latest sh
hostname -i host-gateway
EOF
}

## docker run -it --add-host=host.docker.internal:host-gateway ubuntu bash
docker_ip_fn() {
	# from https://github.com/scionproto/scion/raw/764d6e2afe4765acf24492746c197c32417a57c9/tools/docker-ip

	# Small script to determine the IP of the docker interface. It will use the
	# $DOCKER_IF var if set, otherwise it defaults to docker0.

	set -e -o pipefail

	[ $# -eq 0 ] || { echo "ERROR: set \$DOCKER_IF if you want to specify an interface"; exit 1; }

	DOCKER_HOST_IP=$(ip -o -4 addr ls dev ${DOCKER_IF:-docker0} 2> /dev/null | awk '{print $4}' | cut -f1 -d'/')
	#DOCKER_HOST_IP=$(ip -4 -o addr show docker0 | awk '{print $4}' | cut -d "/" -f 1)
        if test "${DOCKER_HOST_IP}" = ""; then
            exit 1
        else
            echo "${DOCKER_HOST_IP}"
        fi
}


_install_command() {
export DEBIAN_FRONTEND=noninteractive
#    sudo -E apt-get -qq install --no-upgrade "$1" || $($SudoE apt-get -qq update && sudo -E apt-get -qq install --no-upgrade "$1")
    $SudoE apt-get --yes install --no-upgrade "$1" ||:
    if _has_command "$1"; then
         echo "system has now command $1"
    else
         echo "system has still NOT command $1"
         $SudoE apt-get -qq --yes update
         $SudoE apt-get --yes install --no-upgrade "$1"
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
#    sudo -E apt-get -qq install --no-upgrade "$1" || $($SudoE apt-get -qq update && $SudoE apt-get -qq install --no-upgrade "$1")
    $SudoE apt-get --yes install --no-upgrade "$1" ||:
    if [ "x0" = "x$?" ] ; then
         $SudoE apt-get -qq --yes update
         $SudoE apt-get --yes install --no-upgrade "$1"
    fi
}

### _install_if_not_has_command genisoimage
_install_if_not_has_command tree
#_install_if_not_has_command foofeeoo
#

#_install_apt_deb redis-tools
#_install_apt_deb python3-redis 
#_install_apt_deb python3-progress 
#_install_apt_deb python3-progressbar 
#_install_apt_deb python3-humanize
#
_install_apt_deb redis-tools python3-redis python3-progress python3-progressbar python3-humanize



wget -O ccache-download-redis https://github.com/ccache/ccache/raw/v4.8/misc/download-redis
wget -O ccache-upload-redis https://github.com/ccache/ccache/raw/v4.8/misc/upload-redis

echo "eda111306e3d65ac61a86811596d18c283711f00bb5cd76d23df1f4b885d812a *ccache-download-redis" | sha256sum -c -
echo "5305b25e1534601fd102f295a40f5b670dfd63b5f525cd6079d0c5ac86a46c3c *ccache-upload-redis" | sha256sum -c -

$Sudo chmod 755 ccache-upload-redis ccache-download-redis
$Sudo cp -p ccache-upload-redis ccache-download-redis /usr/local/bin/

###curl -L https://github.com/ccache/ccache/releases/download/v4.8/ccache-4.8-linux-x86_64.tar.xz | $Sudo tar -xJvf- --strip-components=1 -C /usr/local/bin/
curl -LORJ https://github.com/ccache/ccache/releases/download/v4.8/ccache-4.8-linux-x86_64.tar.xz
echo "3b35ec9e8af0f849e66e7b5392e2d436d393adbb0574b7147b203943258c6205 *ccache-4.8-linux-x86_64.tar.xz" | sha256sum -c -
$Sudo tar -xJvf ccache-4.8-linux-x86_64.tar.xz --strip-components=1 -C /usr/local/bin/

curl -LORJ https://github.com/berlin4apk/ccache-action/raw/v1.2.105/src/update-ccache-symlinks.sh
curl -LORJ https://github.com/berlin4apk/ccache-action/raw/v1.2.105/third-party/debian-ccache/debian/update-ccache-symlinks.in
echo "98a3cb350fa4918c8f72ea3167705ef57e7fafa8c64fc0f286029e25e1867874 *update-ccache-symlinks.in" | sha256sum -c -
echo "9ba51f7f4983817980c4173282dd09cdba6b5d81d087852831d9ecb69a6cf7ad *update-ccache-symlinks.sh" | sha256sum -c -
$Sudo chmod 755 update-ccache-symlinks.in update-ccache-symlinks.sh
$Sudo cp -p update-ccache-symlinks.in update-ccache-symlinks.sh /usr/local/bin/

$Sudo -l ||:

/usr/local/bin/update-ccache-symlinks.sh ||:

set +eo pipefail

export REDIS_CONF=redis-y9g98g58d
export REDIS_USERNAME=
export REDIS_PASSWORD=

ccache -p
ccache --set-config remote_storage="redis://172.17.0.1|redis://172.18.0.1|redis://host.docker.internal|redis://redis-y9g98g58d|redis://redis-2y9g98g58d|redis://redis"
ccache --set-config reshare=true
ccache --set-config remote_only=true
ccache --set-config hard_link=false
ccache --set-config umask=002
ccache -p

cat <<EOF | $Sudo tee /etc/ccache.conf-04-mod-host | $Sudo tee /usr/local/etc/ccache.conf-04-mod-host
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

docker_redis_ip_test_port_26379
docker_redis_ip_test
docker_redis_ip2_test
docker_redis_ip3_test

set +vx
DOCKER_HOST_IP1=$(docker_ip_fn)
DOCKER_HOST_IP2=$(docker_ip_fn2)
DOCKER_HOST_IP3=$(docker_ip_fn3)
DOCKER_HOST_IP4=$(docker_ip_fn4)
set -vx


serverlist="
redis://172.17.0.1
redis://172.18.0.1
redis://host.docker.internal
redis://host-gateway
redis://redis-y9g98g58d
redis://redis-2y9g98g58d
redis://redis
redis://redis-host
redis://redis-server
redis://localhost
redis://$DOCKER_HOST_IP1
redis://$DOCKER_HOST_IP2
redis://$DOCKER_HOST_IP3
redis://$DOCKER_HOST_IP4
redis://gateway.docker.internal
redis://docker.for.mac.host.internal
redis://docker.for.mac.localhost
redis://docker.for.win.host.internal
redis://docker.for.win.localhost
"
for t in $serverlist; do redis-cli -u $t   ping ||: ; done

PORT=:6379
serverlist="
redis://$DOCKER_HOST_IP1\$PORT
redis://$DOCKER_HOST_IP2\$PORT
redis://$DOCKER_HOST_IP3\$PORT
redis://$DOCKER_HOST_IP4\$PORT
redis://172.17.0.1\$PORT
redis://172.18.0.1\$PORT
redis://host.docker.internal\$PORT
redis://host-gateway\$PORT
redis://redis-y9g98g58d\$PORT
redis://redis-2y9g98g58d\$PORT
redis://redis\$PORT
redis://redis-host\$PORT
redis://redis-server\$PORT
redis://localhost\$PORT
redis://gateway.docker.internal\$PORT
redis://docker.for.mac.host.internal\$PORT
redis://docker.for.mac.localhost\$PORT
redis://docker.for.win.host.internal\$PORT
redis://docker.for.win.localhost\$PORT
"
for t in $serverlist; do redis-cli -u $t   ping ||: ; done

PORT=:26379
serverlist="
redis://$DOCKER_HOST_IP1\$PORT
redis://$DOCKER_HOST_IP2\$PORT
redis://$DOCKER_HOST_IP3\$PORT
redis://$DOCKER_HOST_IP4\$PORT
redis://172.17.0.1\$PORT
redis://172.18.0.1\$PORT
redis://host.docker.internal\$PORT
redis://host-gateway\$PORT
redis://redis-y9g98g58d\$PORT
redis://redis-2y9g98g58d\$PORT
redis://redis\$PORT
redis://redis-host\$PORT
redis://redis-server\$PORT
redis://localhost\$PORT
redis://gateway.docker.internal\$PORT
redis://docker.for.mac.host.internal\$PORT
redis://docker.for.mac.localhost\$PORT
redis://docker.for.win.host.internal\$PORT
redis://docker.for.win.localhost\$PORT
"
for t in $serverlist; do redis-cli -u $t   ping ||: ; done
set -eo pipefail


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
	if [ -r $FILE ]; then
		bash "$FILE"
        fi
	set +vx
done # not needed?? || echo "files mod-host_*.sh not exist"
unset FILE

echo "= 04-mod-host.sh ==== $0 ==== end ==========================================="
