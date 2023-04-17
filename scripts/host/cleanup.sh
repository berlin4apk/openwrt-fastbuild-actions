#!/bin/bash

# Copyright (c) 2019 P3TERX
# From https://github.com/P3TERX/Actions-OpenWrt

set +eo pipefail
export DEBIAN_FRONTEND=noninteractive
/bin/bash -x "export DEBIAN_FRONTEND=noninteractive ; sudo -E apt-get install --yes install --no-upgrade aptitude dpigs || sudo -E apt-get  --yes update ; sudo -E apt-get install --yes install --no-upgrade aptitude dpigs"

# https://book.dpmb.org/debian-paketmanagement.chunked/ch08s16.html
echo "::group::🪣 aptitude search -F '%I %p' --sort installsize '~i' | tail -50 | tac ..."
#aptitude search -F '%I %p' --sort installsize '~i' | tail -15 | tac
aptitude search -F '%I %p' --sort installsize '~i' | tail -50 | tac ||:
echo "::endgroup::"
echo "::group::🪣 dpigs -S -n15 -H  ..."
dpigs -S -n50 -H ||:
echo "::endgroup::"
echo "::group::🪣 dpkg-query -Wf '${Installed-size}\t${Package}\n' | column -t | sort -nr | head -50   ..."
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
sudo rm -rf /usr/share/dotnet
sudo rm -rf /usr/local/share/boost
sudo rm -rf /usr/local/go*
sudo rm -rf /usr/local/lib/android
sudo rm -rf /opt/ghc	# haskell
sudo rm -rf /opt/hostedtoolcache/CodeQL
sudo swapoff /swapfile
sudo rm -f /swapfile
docker rmi "$(docker images -q)"
sudo -E apt-get -q purge azure-cli zulu* hhvm llvm* firefox google* dotnet* powershell openjdk* mysql*

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
sudo rm -rf /var/cache/apt/archives
exit 0
