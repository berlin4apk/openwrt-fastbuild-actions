#!/bin/bash



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


_install_if_not_has_command genisoimage
_install_if_not_has_command tree
#_install_if_not_has_command foofeeoo

