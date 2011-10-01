#!/bin/bash

# common.bash was written by Claude Falguiere
#
# Usage:
# source common.bash
#
# Description
# common initialisation and tasks for other scripts

### Common Initializations

PROJECT_NAME=`grep "^app_name:" SoftwareFactory/config.yaml | sed "s/app_name: '\(.*\)'/\1/"`
INFO_NAME=${PROJECT_NAME}/${PROJECT_NAME}-Info.Plist
CLONE_FOLDER=`grep "^clone_folder:" SoftwareFactory/config.yaml | sed "s/clone_folder: '\(.*\)'/\1/"`


PROJECT_DIR=$(pwd)

LOG_DIR=$PROJECT_DIR/Logs
mkdir -p $LOG_DIR >/dev/null
LOG_FILE=${LOG_DIR}/`date "+Build_%Y-%m-%d_%H%M%S.txt"`

### Common function definitions

function log {
	echo "${1}"
	echo "${1}" >> $LOG_FILE
}
	
function alert_user {
        log "${1}"
        if [ ! -z `which growlnotify` ]; then
                growlnotify `basename $0` -m "${1}"
        fi
}

function exit_ko {
  alert_user "${1}" 
	log "** BUILD FAILED **"
	echo "Check logs $LOG_FILE"
	exit 1
}

function exit_ok {
  alert_user "${1}"
	log "** BUILD SUCCEEDED **"
	exit 0
}

function log_section {
	log " "
	log "############################################################"
	log "##		${1}"
}
