#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
FUNCPATH="${SCRIPTPATH}/.lib/functions.sh"
# shellcheck disable=SC1090
. "${FUNCPATH}"


###
### RSYNC ARGUMENTS
###
RSYNC_ARGS="-- --no-perms"

print_section "03 --no-perms"

### ################################################################################################
### ################################################################################################
###
### CREATE FILES AND DIRS
###
### ################################################################################################
### ################################################################################################

print_headline "Creating files and directories"

###
### Create source and target dir
###
SRC_DIR="$( create_tmp_dir )"
DST_DIR="$( create_tmp_dir )"

FILE1_NAME="file1.txt"
FILE2_NAME="file2.txt"
FILE3_NAME="sub/file3.txt"

FILE1_PERM="677"
FILE2_PERM="777"
FILE3_PERM="676"

###
### Create source files
###
create_file "${SRC_DIR}" "${FILE1_NAME}" "2" "${FILE1_PERM}"
create_file "${SRC_DIR}" "${FILE2_NAME}" "5" "${FILE2_PERM}"
create_file "${SRC_DIR}" "${FILE3_NAME}" "1" "${FILE3_PERM}"


### ################################################################################################
### ################################################################################################
###
### DEFINE CHECKS
###
### ################################################################################################
### ################################################################################################

check() {
	local file="${1}"
	local perm="${2}"
	local destination
	destination="${DST_DIR}/current/$(basename "${SRC_DIR}")"

	print_subline "Validate ${file}"
	check_dst_file_perm "${file}" "${perm}" "$(get_default_dest_file_perm "${perm}")" "${destination}"
}


### ################################################################################################
### ################################################################################################
###
### Run backup (Round 1)
###
### ################################################################################################
### ################################################################################################

print_headline "Backup (Round 1)"

###
### Backup
###
print_subline "Run Backup"
run_backup \
	"${SCRIPTPATH}/../timemachine" \
	"${SRC_DIR}" \
	"${DST_DIR}" \
	"${RSYNC_ARGS}" \
	"full"

###
### Check
###
check "${FILE1_NAME}" "${FILE1_PERM}"
check "${FILE2_NAME}" "${FILE2_PERM}"
check "${FILE3_NAME}" "${FILE3_PERM}"


### ################################################################################################
### ################################################################################################
###
### Run backup (Round 2)
###
### ################################################################################################
### ################################################################################################

print_headline "Backup (Round 2)"

###
### Backup
###
print_subline "Run Backup"
run_backup \
	"${SCRIPTPATH}/../timemachine" \
	"${SRC_DIR}" \
	"${DST_DIR}" \
	"${RSYNC_ARGS}" \
	"incremental"

###
### Check
###
check "${FILE1_NAME}" "${FILE1_PERM}"
check "${FILE2_NAME}" "${FILE2_PERM}"
check "${FILE3_NAME}" "${FILE3_PERM}"
