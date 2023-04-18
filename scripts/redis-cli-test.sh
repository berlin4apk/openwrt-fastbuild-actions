#!/bin/bash

set -eo pipefail

# shellcheck disable=SC1090
#### source "${HOST_WORK_DIR}/scripts/host/docker.sh"
#### configure_docker
#### login_to_registry

echo "= redis-cli-test.sh ==== $0 ==== start ==========================================="

echo "\$1: $1"
echo "\$ENV_JOB_CONTAINER_NETWORK: $ENV_JOB_CONTAINER_NETWORK"

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

if [ "$CI" != "true" ]; then
	echo runing not in CI, no sudo using
else
     _has_command sudo && {
    sudo -n echo 2>/dev/null && SudoVAR="-n $SudoVAR" || SudoVAR="$SudoVAR"
  }
     _has_command sudo && {
    sudo -E echo 2>/dev/null && export SudoE="sudo -E $SudoVAR" || SudoVAR="$SudoVAR"
  }
     _has_command sudo && {
    sudo echo 2>/dev/null && export Sudo="sudo $SudoVAR" || export Sudo=""
  }
fi
  
docker_build_alpine_image() {
#cat <<EOF | docker build --tag alpine -
cat <<EOF | docker buildx build --tag alpine-network-tools -
FROM alpine:latest
RUN set -vx && apk add --no-cache redis bind-tools musl-utils iproute2
EOF
}
docker image inspect alpine-network-tools || docker_build_alpine_image;


#_has_command() {   for cmd do     command -v "$cmd" >/dev/null 2>&1 || return 1   done  }
#_has_command2() {    command -v -- "$1" 2>/dev/null || hash -- "$1" 2>/dev/null   }
#_has_command2 redis-cli || apk add --no-cache redis
docker_redis_ip_test() {
cat <<EOF | docker run --rm -i  $*  --add-host=host.docker.internal:host-gateway --name redis_alpine alpine-network-tools sh
set -vx
command -v -- redis-cli 2>/dev/null || apk add --no-cache redis
echo docker_redis_ip_test


serverlist="
redis://172.17.0.1:6379
redis://172.18.0.1:6379
redis://host.docker.internal:6379
redis://host-gateway:6379
redis://redis-y9g98g58d:6379
redis://redis-2y9g98g58d:6379
redis://redis:6379
redis://redis1:6379
redis://redis2:6379
redis://redis3:6379
redis://redis4:6379
redis://redis5:6379
redis://redis-host:6379
redis://redis-server:6379
redis://localhost:6379
redis://gateway.docker.internal:6379
redis://docker.for.mac.host.internal:6379
redis://docker.for.mac.localhost:6379
redis://docker.for.win.host.internal:6379
redis://docker.for.win.localhost:6379
redis://172.17.0.1:26379
redis://172.18.0.1:26379
redis://host.docker.internal:26379
redis://host-gateway:26379
redis://redis-y9g98g58d:26379
redis://redis-2y9g98g58d:26379
redis://redis:26379
redis://redis1:26379
redis://redis2:26379
redis://redis3:26379
redis://redis4:26379
redis://redis5:26379
redis://redis-host:26379
redis://redis-server:26379
redis://localhost:26379
redis://gateway.docker.internal:26379
redis://docker.for.mac.host.internal:26379
redis://docker.for.mac.localhost:26379
redis://docker.for.win.host.internal:26379
redis://docker.for.win.localhost:26379
redis://172.17.0.1:36379
redis://172.18.0.1:36379
redis://host.docker.internal:36379
redis://host-gateway:36379
redis://redis-y9g98g58d:36379
redis://redis-2y9g98g58d:36379
redis://redis:36379
redis://redis1:36379
redis://redis2:36379
redis://redis3:36379
redis://redis4:36379
redis://redis5:36379
redis://redis-host:36379
redis://redis-server:36379
redis://localhost:36379
redis://gateway.docker.internal:36379
redis://docker.for.mac.host.internal:36379
redis://docker.for.mac.localhost:36379
redis://docker.for.win.host.internal:36379
redis://docker.for.win.localhost:36379
redis://172.17.0.1:46379
redis://172.18.0.1:46379
redis://host.docker.internal:46379
redis://host-gateway:46379
redis://redis-y9g98g58d:46379
redis://redis-2y9g98g58d:46379
redis://redis:46379
redis://redis1:46379
redis://redis2:46379
redis://redis3:46379
redis://redis4:46379
redis://redis5:46379
redis://redis-host:46379
redis://redis-server:46379
redis://localhost:46379
redis://gateway.docker.internal:46379
redis://docker.for.mac.host.internal:46379
redis://docker.for.mac.localhost:46379
redis://docker.for.win.host.internal:46379
redis://docker.for.win.localhost:46379
redis://172.17.0.1:56379
redis://172.18.0.1:56379
redis://host.docker.internal:56379
redis://host-gateway:56379
redis://redis-y9g98g58d:56379
redis://redis-2y9g98g58d:56379
redis://redis:56379
redis://redis1:56379
redis://redis2:56379
redis://redis3:56379
redis://redis4:56379
redis://redis5:56379
redis://redis-host:56379
redis://redis-server:56379
redis://localhost:56379
redis://gateway.docker.internal:56379
redis://docker.for.mac.host.internal:56379
redis://docker.for.mac.localhost:56379
redis://docker.for.win.host.internal:56379
redis://docker.for.win.localhost:56379
"
for t in \$serverlist; do 
#set +vx
	#echo "###########################"
	#echo "########"
	#echo \$t
	#printf "\$t \t\t "
#	printf "\t\t\t %s\n" "\$t"
#printf "%s\t" "\$t"
printf "%s" "\$t"
#printf '\033[%d' 10
#	printf "%s" "\$t"
#	printf "\33[%d;%d" "30" "10"
#	ESC[1;5C
#	printf "\337\33[%d;%dH%s\338" "30" "30" ">"
#	printf "\337\33[%d;%dH%s\338" "$Y" "$X" "$CHAR"
#	printf "\33[%d;%dH%s" "$Y" "$X" "$CHAR"
#	redis-cli -u \$t   ping  ||: ; | tr "\n" " "
#	printf "%5s", "abc"
#	#redis-cli -u \$t   ping  | tr "\n" " "
timeout 3 redis-cli -u \$t   ping  | tr "\n" " "
#outVAR=$(redis-cli -u "\$t"   ping 2>&1 ) 
#printf "\033[0C bbbb"
printf "\033[0L" 
printf "\033[45C "
#printf "\033[40C foooooo"
redis-cli --verbose -u "\$t"   ping 2>&1
#printf "%s" "\$outVAR"
	#echo "###########################"
#	echo "__________________________________________________________________________________________________"
printf "_______________________________________________________________________________________________________________________\n"
done
EOF
}

#for t in \$serverlist; do 
#	#echo "###########################"
#	echo "########"
#	#echo \$t
#	#printf "\$t \t\t "
##	printf "\t\t\t %s\n" "\$t"
#printf "%s\t\t" "\$t"
##	redis-cli -u \$t   ping  ||: ; | tr "\n" " "
##	rediscliout= # redis-cli -u \$t   ping  | tr "\n" " " 
#	redis-cli -u \$t   ping  2>&1 | tr "\n" " " 
#	#echo "\$t \t\t $rediscliout"
#	#echo "###########################"
#	echo "########________________________________________________________________________________________________"
##	printf "\n########__________________________________________________________________________________________\n"
#done




docker_redis_ip_test_port_26379() {
cat <<EOF | docker run --rm -i  $*   --add-host=host.docker.internal:host-gateway --name redis_alpine alpine-network-tools sh
set -vx
apk add --no-cache redis >/dev/null
echo docker_redis_ip_test_port_26379
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
cat <<EOF | docker run --rm -i  $*   --add-host=host.docker.internal:host-gateway --name redis_alpine alpine-network-tools sh
set -vx
apk add --no-cache bind-tools >/dev/null
echo docker_redis_ip2_test
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
cat <<EOF | docker run --rm -i  $*   --add-host=host.docker.internal:host-gateway --name redis_alpine alpine-network-tools sh
set -vx
apk add --no-cache musl-utils >/dev/null
echo docker_redis_ip3_test
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


HOST_SELF_redis_ip_test() {
cat <<EOF | bash
set -vx
echo HOST_SELF_redis_ip_test
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
for t in \$serverlist; do redis-cli -u \$t   ping ||: ; done
EOF
}

HOST_SELF_redis_ip_test_port_6379() {
cat <<EOF | bash
set -vx
echo HOST_SELF_redis_ip_test_port_6379
PORT=:6379
serverlist="
redis://\$DOCKER_HOST_IP1\$PORT
redis://\$DOCKER_HOST_IP2\$PORT
redis://\$DOCKER_HOST_IP3\$PORT
redis://\$DOCKER_HOST_IP4\$PORT
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


HOST_SELF_redis_ip_test_port_26379() {
cat <<EOF | bash
PORT=:26379
echo HOST_SELF_redis_ip_test_port_26379
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
for t in \$serverlist; do redis-cli -u \$t   ping ||: ; done
EOF
}

set -eo pipefail



docker_alpine_ip() {
#cat <<EOF | docker run --rm -i  $*   alpine:latest sh
cat <<EOF | docker run --rm -i  $*   alpine-network-tools sh
apk add --no-cache iproute2 >/dev/null
ip -4 route show default | cut -d' ' -f3
EOF
}

docker_ip_fn2() {
cat <<EOF | docker run --rm -i  $*   busybox:latest sh
ip -4 route show default | cut -d' ' -f3
EOF
}

docker_ip_fn3() {
cat <<EOF | docker run --rm -i  $*   --add-host=host.docker.internal:host-gateway busybox:latest sh
hostname -i host.docker.internal
EOF
}

docker_ip_fn4() {
cat <<EOF | docker run --rm -i  $*   --add-host=host.docker.internal:host-gateway busybox:latest sh
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
if [ "$CI" != "true" ]; then
	echo runing not in CI, no apt install
else
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
if [ "$CI" != "true" ]; then
	echo runing not in CI, no apt install
else
export DEBIAN_FRONTEND=noninteractive
#    sudo -E apt-get -qq install --no-upgrade "$1" || $($SudoE apt-get -qq update && $SudoE apt-get -qq install --no-upgrade "$1")
    $SudoE apt-get --yes install --no-upgrade "$1" ||:
    if [ "x0" = "x$?" ] ; then
         $SudoE apt-get -qq --yes update
         $SudoE apt-get --yes install --no-upgrade "$1"
    fi
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


_install_ccache_download_redis() {
wget -O ccache-download-redis https://github.com/ccache/ccache/raw/v4.8/misc/download-redis
wget -O ccache-upload-redis https://github.com/ccache/ccache/raw/v4.8/misc/upload-redis

echo "eda111306e3d65ac61a86811596d18c283711f00bb5cd76d23df1f4b885d812a *ccache-download-redis" | sha256sum -c -
echo "5305b25e1534601fd102f295a40f5b670dfd63b5f525cd6079d0c5ac86a46c3c *ccache-upload-redis" | sha256sum -c -

if [ "$CI" != "true" ]; then
	echo runing not in CI, no cp -p ccache-upload-redis ccache-download-redis /usr/local/bin/
else
$Sudo chmod 755 ccache-upload-redis ccache-download-redis
$Sudo cp -p ccache-upload-redis ccache-download-redis /usr/local/bin/
fi

###curl -L https://github.com/ccache/ccache/releases/download/v4.8/ccache-4.8-linux-x86_64.tar.xz | $Sudo tar -xJvf- --strip-components=1 -C /usr/local/bin/
[[ -e ccache-4.8-linux-x86_64.tar.xz ]] || curl -LORJ https://github.com/ccache/ccache/releases/download/v4.8/ccache-4.8-linux-x86_64.tar.xz
echo "3b35ec9e8af0f849e66e7b5392e2d436d393adbb0574b7147b203943258c6205 *ccache-4.8-linux-x86_64.tar.xz" | sha256sum -c -
$Sudo tar -xJvf ccache-4.8-linux-x86_64.tar.xz --strip-components=1 -C /usr/local/bin/

[[ -e update-ccache-symlinks.sh ]] || curl -LORJ https://github.com/berlin4apk/ccache-action/raw/v1.2.105/src/update-ccache-symlinks.sh
[[ -e update-ccache-symlinks.in ]] || curl -LORJ https://github.com/berlin4apk/ccache-action/raw/v1.2.105/third-party/debian-ccache/debian/update-ccache-symlinks.in
echo "98a3cb350fa4918c8f72ea3167705ef57e7fafa8c64fc0f286029e25e1867874 *update-ccache-symlinks.in" | sha256sum -c -
echo "9ba51f7f4983817980c4173282dd09cdba6b5d81d087852831d9ecb69a6cf7ad *update-ccache-symlinks.sh" | sha256sum -c -
if [ "$CI" != "true" ]; then
	echo runing not in CI, no apt install
else
	$Sudo chmod 755 update-ccache-symlinks.in update-ccache-symlinks.sh
	$Sudo cp -p update-ccache-symlinks.in update-ccache-symlinks.sh /usr/local/bin/
fi

$Sudo -l ||:

/usr/local/bin/update-ccache-symlinks.sh ||:
}

if [ "$CI" != "true" ]; then
	echo runing not in CI, no _install_ccache_download_redis
else
	_install_ccache_download_redis
fi

set +eo pipefail

export REDIS_CONF=redis-y9g98g58d
export REDIS_USERNAME=
export REDIS_PASSWORD=

ccache -p
###ccache --set-config remote_storage="file://home/builder/.ccache|redis://172.17.0.1|redis://172.18.0.1|redis://host.docker.internal|redis://redis-y9g98g58d|redis://redis-2y9g98g58d|redis://redis"
[[ "$CI" == "true" ]] && ccache --set-config remote_storage="file:/${HOST_CCACHE_DIR}|file:/${BUILDER_CCACHE_DIR}"
#ccache --set-config reshare=true
#ccache --set-config remote_only=true
ccache --set-config hard_link=false
ccache --set-config umask=002
ccache -p

[[ "$CI" == "true" ]] && cat <<EOF | $Sudo tee /etc/ccache.conf-04-mod-host | $Sudo tee /usr/local/etc/ccache.conf-04-mod-host
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




if [ "$CI" != "true" ]; then
	echo "runing not in CI, no HOST_SELF_redis_ip_test"
else
set +vx
DOCKER_HOST_IP1=$(docker_ip_fn)
DOCKER_HOST_IP2=$(docker_ip_fn2)
DOCKER_HOST_IP3=$(docker_ip_fn3)
DOCKER_HOST_IP4=$(docker_ip_fn4)
set -vx

HOST_SELF_redis_ip_test
HOST_SELF_redis_ip_test_port_6379
HOST_SELF_redis_ip_test_port_26379
fi




# docker run --network ${{ job.container.network }} --hostname redis-cli --name redis-cli -d redis:7.0.10-alpine3.17 
if [ "$CI" != "true" ]; then
	echo "runing not in CI"
#	docker_redis_ip_test  --network "$*"
# working #	mypong=$( docker_redis_ip_test  --network "$*" | tee /dev/tty | grep -B1 PONG )
#	mypong=$( docker_redis_ip_test  --network "$*" | tee /dev/tty | grep PONG )
#	echo "$mypong"
#[[ "$*" != "" ]] && echo "call docker with --network $*"
#[[ "$*" != "" ]] && docker_redis_ip_test  --network "$*"
#[[ "$*" == "" ]] && echo "call docker without --network "
#[[ "$*" == "" ]] && docker_redis_ip_test

[[ "$*" != "" ]] && echo "call docker with --network $*"
[[ "$*" != "" ]] && mypong=$( docker_redis_ip_test  --network "$*" | tee /dev/tty | grep PONG ) ; echo "$mypong"
[[ "$*" == "" ]] && echo "call docker without --network "
[[ "$*" == "" ]] && mypong=$( docker_redis_ip_test | tee /dev/tty | grep PONG ) ; echo "$mypong"



#	docker_redis_ip_test_port_26379  --network "$*"
#	docker_redis_ip2_test  --network "$*"
#	docker_redis_ip3_test  --network "$*"
else
#	docker_redis_ip_test  --network "$*"
# in CI not fully working #	mypong=$( docker_redis_ip_test  --network "$*" | tee /dev/tty | grep -B1 PONG )
#	mypong=$( docker_redis_ip_test  --network "$*" | tee /dev/tty | grep PONG )
#	echo "$mypong"
#docker_redis_ip_test  --network "$*"
#docker_redis_ip_test  --network "$*" | grep PONG
#[[ "$*" != "" ]] && echo "call docker with --network $*"
#[[ "$*" != "" ]] && docker_redis_ip_test  --network "$*"
#[[ "$*" == "" ]] && echo "call docker without --network "
#[[ "$*" == "" ]] && docker_redis_ip_test

[[ "$*" != "" ]] && echo "call docker with --network $*"
[[ "$*" != "" ]] && mypong=$( docker_redis_ip_test  --network "$*" | tee /dev/tty | grep PONG ) ; echo "$mypong"
[[ "$*" == "" ]] && echo "call docker without --network "
[[ "$*" == "" ]] && mypong=$( docker_redis_ip_test | tee /dev/tty | grep PONG ) ; echo "$mypong"

#	docker_redis_ip_test_port_26379  --network "$*"
#	docker_redis_ip2_test  --network "$*"
#	docker_redis_ip3_test  --network "$*"
fi




echo "= UIDs on Host ==== $0 ==============================================="
	set -vx
id -u
id -g
id
	set +vx
echo "= UIDs on Host ==== $0 ==============================================="

if [ "$CI" != "true" ]; then
	echo runing not in CI, no apt install
else
for FILE in redis-cli-test_*.sh; do
	set -vx
	#[ -e "$FILE" ] && . "$FILE"
	if [ -r $FILE ]; then
		bash "$FILE"
        fi
	set +vx
done # not needed?? || echo "files redis-cli-test_*.sh not exist"
unset FILE
fi

echo "= redis-cli-test.sh ==== $0 ==== end ==========================================="
