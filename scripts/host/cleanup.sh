#!/bin/bash

# Copyright (c) 2019 P3TERX
# From https://github.com/P3TERX/Actions-OpenWrt

set +eo pipefail
export DEBIAN_FRONTEND=noninteractive
export LANG=C

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
    sudo -E echo 2>/dev/null && SudoE="sudo -E $SudoVAR" || SudoVAR="$SudoVAR"
  }
     _has_command sudo && {
    sudo echo 2>/dev/null && Sudo="sudo $SudoVAR" || Sudo=""
  }

# https://book.dpmb.org/debian-paketmanagement.chunked/ch08s16.html
/bin/bash -x -c "export DEBIAN_FRONTEND=noninteractive ; sudo -E apt-get install --yes --no-upgrade --no-install-recommends --no-install-suggests eatmydata aptitude debian-goodies  || sudo -E apt-get  --yes update ; sudo -E apt-get install --yes --no-upgrade --no-install-recommends --no-install-suggests eatmydata aptitude debian-goodies"

     _has_command eatmydata && {
    eatmydata echo 2>/dev/null && Eatmydata="eatmydata" || Eatmydata=""
  }


_got_more_space() {
  # well, this is exactly `for cmd in "$@"; do`
Vtotal=${Vtotal:-0}
Vtotalold="$Vtotal"
Vtotal=$(df --total / | awk 'END {print $4}')
bc <<<"$Vtotalold-$Vtotal" | numfmt --to=iec
#  for cmd do
#    command -v "$cmd" >/dev/null 2>&1 || return 1
#  done
}




# https://book.dpmb.org/debian-paketmanagement.chunked/ch08s16.html
echo "::group::🪣 aptitude search -F '%I %p' --sort installsize '~i' | tail -50 | tac ..."
#aptitude search -F '%I %p' --sort installsize '~i' | tail -15 | tac
aptitude search -F '%I %p' --sort installsize '~i' | tail -50 | tac ||:
echo "::endgroup::"
echo "::group::🪣 dpigs -S -n15 -H  ..."
dpigs -S -n50 -H ||:
echo "::endgroup::"
echo "::group::🪣 dpkg-query -Wf Installed-size Package | column -t | sort -nr | head -50   ..."
dpkg-query -Wf '${Installed-size}\t${Package}\n' | column -t | sort -nr | head -50 | numfmt --to=iec  ||:
echo "::endgroup::"

echo "::group::🪣 df -ia  ..."
df -iaT | tee "$(basename "$0")_df-iaT.out"
echo "::endgroup::"

echo "::group::🪣 df -ah  ..."
df -ahT --total | tee  "$(basename "$0")_df-ahT.out"
echo "::endgroup::"

echo "::group::🪣 df -h  ..."
df -hT --total | tee  "$(basename "$0")_df-hT.out"
echo "::endgroup::"

echo "Deleting files, please wait ..."
#sudo rm -rf /usr/share/dotnet /usr/local/share/boost /usr/local/go* /usr/local/lib/android /opt/ghc
# https://github.com/easimon/maximize-build-space/blob/master/action.yml
set -x
free -h
sudo swapoff /swapfile
sudo $Eatmydata rm -f /swapfile
free -h
_got_more_space
sudo $Eatmydata rm -rf /usr/share/dotnet
_got_more_space
sudo $Eatmydata rm -rf /usr/local/share/boost
_got_more_space
sudo $Eatmydata rm -rf /usr/local/go*
_got_more_space
sudo $Eatmydata rm -rf /usr/local/lib/android
_got_more_space
sudo $Eatmydata rm -rf /opt/ghc	# haskell
_got_more_space
sudo $Eatmydata rm -rf /opt/hostedtoolcache/CodeQL
_got_more_space
$Eatmydata docker rmi "$(docker images -q)"
_got_more_space
#sudo -E apt-get -q purge azure-cli zulu* hhvm llvm* firefox microsoft-edge* google-cloud-sdk google* dotnet* powershell openjdk* temurin-*-jdk mysql*
sudo -E $Eatmydata apt-get purge azure-cli zulu* hhvm llvm* firefox microsoft-edge* google-cloud-sdk google* dotnet* powershell openjdk* temurin-*-jdk mysql*
_got_more_space
sudo -E $Eatmydata apt-get clean 
_got_more_space
set +x

# https://book.dpmb.org/debian-paketmanagement.chunked/ch08s16.html
echo "::group::🪣 aptitude search -F '%I %p' --sort installsize '~i' | tail -50 | tac ..."
#aptitude search -F '%I %p' --sort installsize '~i' | tail -15 | tac
aptitude search -F '%I %p' --sort installsize '~i' | tail -50 | tac ||:
echo "::endgroup::"
echo "::group::🪣 dpigs -S -n15 -H  ..."
dpigs -S -n50 -H ||:
echo "::endgroup::"
echo "::group::🪣 dpkg-query -Wf '${Installed-size}\t${Package}\n' | column -t | sort -nr | head -50   ..."
dpkg-query -Wf '${Installed-size}\t${Package}\n' | column -t | sort -nr | head -50 | numfmt --to=iec ||:
echo "::endgroup::"

df -ah > "$(basename "$0")_df-ah2.out"

set -vx
head -1 "$(basename "$0")_df-hT.out" ; diff -u0 "$(basename "$0")_df-hT.out" <(df -hT --total) | sed -n '/^+[^+]/ s/^+//p' ||:
head -1 "$(basename "$0")_df-hT.out" ; diff --new-line-format="%L" --old-line-format="" --unchanged-line-format="" "$(basename "$0")_df-hT.out" <(df -hT --total) ||:
set +vx

#sudo rm -rf /etc/apt/sources.list.d/* /var/cache/apt/archives
sudo $Eatmydata rm -rf /var/cache/apt/archives
exit 0
