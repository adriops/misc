#!/usr/bin/env bash
source ${BASEDIR}/utils/logging-format.sh

function __check_mount() {
  local _dir=${1}

  if mountpoint -q $_dir; then
    __log_info "Folder $_dir is mounted"
  else
    __error_exit "Folder $_dir isn't mounted. It needs to be a mounted external device/hard drive"
  fi
}