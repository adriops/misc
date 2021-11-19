#!/usr/bin/env bash
BASEDIR=$(realpath "$(dirname "${BASH_SOURCE}")")

source ${BASEDIR}/utils/logging-format.sh
source ${BASEDIR}/utils/common-functions.sh

# Set main options
set -o nounset
set -o pipefail

# Log level
ERROR=1
WARN=1
INFO=1
DEBUG=0

# Set vars
BKDIR=
BKPATH="/mnt/temp"
TMPDIR="/var/tmp"
DAYS_TO_DELETE=10

while getopts ":b:df:hr:t:" opt
do
  case ${opt} in
    h )
      echo "
      Usage: ${0} [options]
      Options:
          -b <path-to-file/directory>       Path to backup.
          -d                                Set log level to debug.
          -f <path-to-file>                 File list to backup.
          -h                                Print this help.
          -r <days> (Default 10)            Days to remove older backups files.
          -t <path-to-save>                 Directory where save the backups.
      "
      exit 0
      ;;
    b )
      __start_footprint

      BKDIR=${OPTARG}
      __log_debug "BKDIR = ${BKDIR}"
      ;;
    d )
      DEBUG=1
      ;;
    f )
      __start_footprint

      declare -a BKDIR
      while read path;
      do
        BKDIR+=(${path})
      done < ${OPTARG}
      __log_debug "BKDIR = ${BKDIR[@]}"
      ;;
    r )
      if [[ ${OPTARG} =~ ^[0-9]+$ ]]; then
        DAYS_TO_DELETE=${OPTARG}
      else
        __error_exit "The days parameter must be an integer"
        __end_footprint
      fi
      ;;
    t )
      if [[ -d ${OPTARG} ]]; then
        BKPATH=${OPTARG}
      else
        __error_exit "The path specified in -t argument isn't a directory"
        __end_footprint
      fi
      ;;
    \? )
      echo "Invalid option: -${OPTARG}" 1>&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

# Functions
function _make_bk() {
  local _BKDIR=${1}
  local _BKPATH=${2}

  # Name of tar.gz depending if file or directory
  if [[ -f ${_BKDIR} ]]; then
    _FILENAME=${_BKDIR##*/}

    # Check if filename has extension ('.txt', '.jpg' etc) or not for tar name
    if [[ ${_FILENAME} =~ \.*$ ]]; then
      local _TARFILE="${_FILENAME%.*}_$(date +'%Y-%m-%d_%H%M').tar.gz"
    else
      local _TARFILE="${_FILENAME}_$(date +'%Y-%m-%d_%H%M').tar.gz"
    fi
  elif [[ -d ${_BKDIR} ]]; then
    local _TARFILE="${_BKDIR##*/}_$(date +'%Y-%m-%d_%H%M').tar.gz"
  fi
  __log_debug "TARFILE = ${_TARFILE}"

  # Go to parent directory
  __log_debug "Go to directory ${_BKDIR%/*}"
  cd ${_BKDIR%/*}

  # Create tar.gz file
  __log_info "Create tar.gz from $_BKDIR with name ${_TARFILE}"
  tar czf "${TMPDIR}/${_TARFILE}" ${_BKDIR##*/} || __log_warning "Error compressing ${_BKDIR##*/} folder. Review the error, continue"

  # Copy tar file to backup directory
  __log_info "Copy ${_TARFILE} to ${_BKPATH}"
  rsync -r -e cp "${TMPDIR}/${_TARFILE}" ${_BKPATH}

  # Remove temporal tar file
  __log_info "Delete ${_TARFILE} from ${TMPDIR}"
  rm "${TMPDIR}/${_TARFILE}"
}

function _delete_old_files() {
  local _BKPATH=${1}
  local _DAYS_TO_DELETE=${2}

  # Find backup files older than DAYS_TO_DELETE var
  declare -a _TO_DELETE=()
  readarray -d '' _TO_DELETE < <(find ${_BKPATH} -maxdepth 1 -mtime +${_DAYS_TO_DELETE} -type f)

  # Check if there are any files to delete
  if [[ -z ${_TO_DELETE[@]} ]]; then
    __log_info "There are no files older than ${_DAYS_TO_DELETE} days to delete"
  else
    __log_debug "TO_DELETE = ${_TO_DELETE}"

    for file in ${_TO_DELETE[@]}
    do
      __log_debug "File in loop for delete: ${file}"
      rm -R ${file}
      __log_info "[DELETE] File ${file} deleted"
    done
  fi
}

# Main flow
function main() {
  # Check if files or directory to backup is defined
  if [[ -z ${BKDIR[@]} ]]; then
    __error_exit "File/folder to backup not specified. Use -b or -f arguments to specify"
    __end_footprint
  fi

  __log_debug "BKPATH = ${BKPATH}"

  # Check if destination folder for backups is mounted
  __check_mount ${BKPATH}

  # Loop for call backup function for ever file/directory specified
  for path in ${BKDIR[@]}
  do
    __log_debug "Path in loop for backup: ${path}"
    if [[ -f ${path} || -d ${path} ]]; then
      _make_bk $path ${BKPATH}
      __log_info "[OK] Backup of ${path} done"
    else
      __log_warning "Path ${path} not exist. Review the path, continue"
    fi
  done

  # Delete older backup files
  __log_debug "DAYS_TO_DELETE = ${DAYS_TO_DELETE}"
  _delete_old_files ${BKPATH} ${DAYS_TO_DELETE}

  __end_footprint
}

main
