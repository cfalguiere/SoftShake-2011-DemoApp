#!/bin/bash
#
# push.bash was written by David Gageot and modified by Claude Falguiere
#
# Usage:
# ./push.bash
#
# Description
# based on the "unbreakable build" from David Gageot
# clone the repository, merge with other developer changes, build the project and push to the remote repository if build is successful
#
# Dependencies
# rakefile.rb, config.yaml, common.bash
#

source SoftwareFactory/common.bash

function alert_user {
	echo "${1}"
	if [ ! -z `which growlnotify` ]; then
		growlnotify `basename $0` -m "${1}"
	fi	
}

function exit_ko {
	alert_user "${1}"; exit 1
}

function exit_ok {
	alert_user "${1}"; exit 0
}


PROJECT_DIR=$(pwd)
BRANCH=$(git branch --no-color | awk '$1=="*" {print $2}')
if [ "$BRANCH" == "(no" ]
then
	exit_ko "Exiting on No branch"
fi


ORIGIN=$(git remote -v | awk '$1=="origin" && $3=="(push)" {print $2}')

log_section "git fetch, commit all  and rebase"

git fetch
git add -A; git ls-files --deleted -z | xargs -0 -I {} git rm {}; git commit -m "wip"
git rebase origin/${BRANCH}

if [ "$?" -ne 0 ]
then
	git rebase --abort
	git log -n 1 | grep -q -c "wip" && git reset HEAD~1
	exit_ko "Unable to rebase. please pull or rebase and fix conflicts manually."
fi
git log -n 1 | grep -q -c "wip" && git reset HEAD~1

log "git clone projet to private build"

if [ "${CLONE_FOLDER}" = "" ]
then 
  	exit_ko "missing CLONE_FOLDER name"
fi
if [ -e $FILE ]
then 
  rm -Rf $CLONE_FOLDER
fi
git clone -slb "${BRANCH}" . "${CLONE_FOLDER}"
if [ $? -ne 0 ]; then
	exit_ko "Unable to clone the git repository"
fi

cd $CLONE_FOLDER

log_section "rake package"

#rake build test package
rake package | awk -f SoftwareFactory/logFilter.awk 

BUILD_RESULT=$?

if [ $BUILD_RESULT -ne 0 ]; then
	exit_ko "Unable to build"
fi

log_section "git push"

git push $ORIGIN $BRANCH
if [ $? -ne 0 ]; then
	exit_ko "Unable to push"
fi

cd ${PROJECT_DIR} && git fetch


exit_ok "Yet another successful push!"
