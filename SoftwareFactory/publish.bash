#!/bin/bash

# publish.bash was written Claude Falguiere
#
# Usage:
# publish.bash PROJECT_NAME BUNDLE_VERSION RHOST WWW_PATH KEY_PATH
#
# Description
# rsync the app bundle with the enterprise mobile store
#
# Dependencies
# config.yaml, publish.bash, logFilter.awk
#

source SoftwareFactory/common.bash
SCRIPT_NAME="Publish"

if [ $# -ne 5 ]; then
	echo "Usage: $0 PROJECT_NAME BUNDLE_VERSION RHOST WWW_PATH KEY_PATH"
	exit_ko "Missing parameters $*"
fi

PROJECT_NAME=$1
BUNDLE_VERSION=$2
RHOST=$3
WWW_PATH=$4
KEY_PATH=$5
#echo "PROJECT_NAME $PROJECT_NAME"
#echo "BUNDLE_VERSION $BUNDLE_VERSION"
#echo "RHOST $RHOST"
#echo "WWW_PATH  $WWW_PATH"
#echo "KEY_PATH  $KEY_PATH"

#echo "BUILD_FOLDER $BUILD_FOLDER"
#echo "CLONE_FOLDER $CLONE_FOLDER"

if [ "$BUILD_FOLDER" == "" ]; then
    BUILD_FOLDER=$CLONE_FOLDER
fi

### publish process

log "$SCRIPT_NAME: Provisioning $BUNDLE_VERSION ..."

SOURCE_DIR=${BUILD_FOLDER}/pkg/${BUNDLE_VERSION}
chmod -R a-wx,a+rX,u+w $SOURCE_DIR

DEST_DIR=${WWW_PATH}/apps/${PROJECT_NAME}/

rsync -av -e "ssh -o IdentityFile=${KEY_PATH}" ${SOURCE_DIR} ${RHOST}:${DEST_DIR}
if [ $? -ne 0 ]; then
        exit_ko "Unable to rsync"
fi

exit_ok "$SCRIPT_NAME: Project published with version ${BUNDLE_VERSION}"


