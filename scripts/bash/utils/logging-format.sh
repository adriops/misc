#!/usr/bin/env bash

TIMESTAMP="date --iso-8601=seconds"

function __log_error() {
  [[ "${ERROR}" == "1" ]] && echo -e "$(${TIMESTAMP}) [ERROR]: $*"
}

function __log_warning() {
  [[ "${WARN}" == "1" ]] && echo -e "$(${TIMESTAMP}) [WARN]: $*"
}

function __log_debug() {
  [[ "${DEBUG}" == "1" ]] && echo -e "$(${TIMESTAMP}) [DEBUG]: $*"
}

function __log_info() {
  [[ "${INFO}" == "1" ]] && echo -e "$(${TIMESTAMP}) [INFO]: $*"
}

function __error_exit() {
  __log_error "$1" 1>&2
  exit 1
}

function __start_footprint() {
  echo -e "----- START at $(date +'%Y-%m-%d %H:%M') -----"
}

function __end_footprint() {
  echo -e "----- END at $(date +'%Y-%m-%d %H:%M') -----"
}