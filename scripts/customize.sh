#!/bin/bash

#=================================================
# https://github.com/tete1030/openwrt-fastbuild-actions
# Description: FAST building OpenWrt with Github Actions and Docker!
# Lisence: MIT
# Author: Texot
#=================================================

set -eo pipefail

# shellcheck disable=SC1090
source "${BUILDER_WORK_DIR}/scripts/lib/gaction.sh"

if [ -z "${OPENWRT_COMPILE_DIR}" ] || [ -z "${OPENWRT_CUR_DIR}" ] || [ -z "${OPENWRT_SOURCE_DIR}" ]; then
  echo "::error::'OPENWRT_COMPILE_DIR', 'OPENWRT_CUR_DIR' or 'OPENWRT_SOURCE_DIR' is empty" >&2
  exit 1
fi

if [ "x${TEST}" = "x1" ]; then
  OPENWRT_CUR_DIR="${OPENWRT_COMPILE_DIR}"
  _set_env OPENWRT_CUR_DIR
  exit 0
fi

echo "Executing cat config_*.diff"
bash -xc "wc -l ${BUILDER_PROFILE_DIR}/config.diff" ||:
bash -xc "wc -l ${BUILDER_PROFILE_DIR}/.config.diff" ||:
bash -xc "wc -l ${BUILDER_PROFILE_DIR}/.config" ||:
set -vx
for FILE in "${BUILDER_PROFILE_DIR}"/config_*.diff; do
	set -vx
	if [ -f "$FILE" ]; then
	  (
		#[ -e "$FILE" ] && . "$FILE"
		#bash "$FILE"
		ls -la -- *config* *.config* ||:
		#mv .config .config.diff
		#cat .config.diff | tee -a .config
		ls -la "$FILE" ||:
		#cat "$FILE" | tee -a .config.diff
		tee -a config.diff < "$FILE"
	    # To set final status of the subprocess to 0, because outside the parentheses the '-eo pipefail' is still on
	    true
	  )
	fi
	set +vx
done
unset FILE
set +vx
bash -xc "wc -l ${BUILDER_PROFILE_DIR}/config.diff" ||:
bash -xc "wc -l ${BUILDER_PROFILE_DIR}/.config.diff" ||:
bash -xc "wc -l ${BUILDER_PROFILE_DIR}/.config" ||:

cp "${BUILDER_PROFILE_DIR}/config.diff" "${OPENWRT_CUR_DIR}/.config"

echo "Applying patches..."
if [ -n "$(ls -A "${BUILDER_PROFILE_DIR}/patches" 2>/dev/null)" ]; then
  (
    if [ "x${NONSTRICT_PATCH}" = "x1" ]; then
        set +eo pipefail
    fi

    find "${BUILDER_PROFILE_DIR}/patches" -type f -name '*.patch' -print0 | sort -z | xargs -I % -t -0 -n 1 sh -c "cat '%'  | patch -d '${OPENWRT_CUR_DIR}' -p0 --forward"
    # To set final status of the subprocess to 0, because outside the parentheses the '-eo pipefail' is still on
    true
  )
fi

SYNC_EXCLUDES="
/bin
/.ccache
/dl
/tmp
/build_dir
/staging_dir
/toolchain
/logs
*.o
key-build*
"
declare -a sync_exclude_opts=()
while IFS= read -r line; do
  if [[ -z "${line// }" ]]; then
    continue
  fi
  sync_exclude_opts+=( "--exclude=${line}" )
done <<< "${SYNC_EXCLUDES}"

echo "Copying base files..."
if [ -n "$(ls -A "${BUILDER_PROFILE_DIR}/files" 2>/dev/null)" ]; then
  # feeds.conf is handled in update_feeds.sh
  rsync -camv --no-t "${sync_exclude_opts[@]}" --exclude="/feeds.conf" --exclude="/.config" \
    "${BUILDER_PROFILE_DIR}/files/" "${OPENWRT_CUR_DIR}/"
fi

###  _set_env HOST_CCACHE_DIR BUILDER_CCACHE_DIR HOST_DLCCACHE_DIR BUILDER_DLCCACHE_DIR
echo "export HOST_CCACHE_DIR	BUILDER_CCACHE_DIR	HOST_DLCCACHE_DIR	BUILDER_DLCCACHE_DIR"
#export HOST_CCACHE_DIR
#export BUILDER_CCACHE_DIR
#export HOST_DLCCACHE_DIR
#export BUILDER_DLCCACHE_DIR
export -p | grep -E "HOST_CCACHE_DIR|BUILDER_CCACHE_DIR|HOST_DLCCACHE_DIR|BUILDER_DLCCACHE_DIR"

echo "Executing custom.sh"
if [ -f "${BUILDER_PROFILE_DIR}/custom.sh" ]; then
  (
    cd "${OPENWRT_CUR_DIR}"
    /bin/bash "${BUILDER_PROFILE_DIR}/custom.sh"
  )
fi

echo "Executing custom_*.sh"
set -vx
for FILE in "${BUILDER_PROFILE_DIR}"/custom_*.sh; do
	set -vx
	if [ -f "$FILE" ]; then
	  (
	    cd "${OPENWRT_CUR_DIR}"
	    /bin/bash -x "$FILE"
	    # To set final status of the subprocess to 0, because outside the parentheses the '-eo pipefail' is still on
	    true
	  )
	fi
	set +vx
done
unset FILE
set +vx


# Restore build cache and timestamps
if [ "x${OPENWRT_CUR_DIR}" != "x${OPENWRT_COMPILE_DIR}" ]; then
  echo "Syncing rebuilt source code to work directory..."
echo "::group::🪣 rsync Syncing rebuilt source code to work directory..."
  # sync files by comparing checksum --delete
###  rsync -camv --no-t --delete "${sync_exclude_opts[@]}" \
  rsync -cam --stats --no-t --delete "${sync_exclude_opts[@]}" \
    "${OPENWRT_CUR_DIR}/" "${OPENWRT_COMPILE_DIR}/"
echo "::endgroup::"
###echo "::group::🪣 rm -rf --verbose ${OPENWRT_CUR_DIR} Syncing rebuilt source code to work directory..."
  rm -rf "${OPENWRT_CUR_DIR}"
###  rm -rf --verbose "${OPENWRT_CUR_DIR}"
###echo "::endgroup::"
  OPENWRT_CUR_DIR="${OPENWRT_COMPILE_DIR}"
  _set_env OPENWRT_CUR_DIR
fi

echo "FORCE mkdir -p ${OPENWRT_CUR_DIR}/dl"
DEST="${OPENWRT_CUR_DIR}/dl"
if [ ! -d "$DEST" ]; then 
  if [ -L "$DEST" ]; then
    # It is a symbolic links #
    echo "Symbolic link found for ${OPENWRT_CUR_DIR}/dl ..."
  else
    # It is a directory #
    echo "Directory ${OPENWRT_CUR_DIR}/dl not found do: mkdir -p ${OPENWRT_CUR_DIR}/dl ..."
    mkdir -p "${OPENWRT_CUR_DIR}"/dl
  fi
fi

