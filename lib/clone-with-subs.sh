#!/bin/bash

# Type of script: unattended
# To be runned on: -
# To be runned by: root
# Arguments: $REPO $BRANCH $TARGET
# Local dependencies: git-archive-all.sh
# Remote dependencies: - none -
# Short description: A script to obtain a working copy form $REPOSITORY $BRANCH on non existant $TARGET (with submodules)

#set -x

E_BADARGS=65
E_BADDEPS=66
E_TARGET_EXISTS=67

EXPECTED_ARGS=3

#echo $0
if [ $# -lt $EXPECTED_ARGS ]
then
  echo " This script expect at least $EXPECTED_ARGS arguments instead of $#"
  exit $E_BADARGS
fi

GIT=$(which git)
CHMOD=$(which chmod)
CHOWN=$(which chown)
TAR=$(which tar)
SED=$(which sed)
AWK=$(which awk)
MKDIR=$(which mkdir)

#Dependency checks
S_DIR=$($(which dirname) $($(which readlink) -f "$0"))
LIB="${S_DIR}/lib"
IFS=","
#DEPS=(git-archive-all.sh,git-archive-all2.sh)
DEPS=( git-archive-all.sh )
#echo $LIB
if [ -d $LIB ]; then
#  echo "LIB dir exists: $LIB"
  for dependency in $DEPS; do
    if [ ! -x "$($(which readlink) -f $LIB/$dependency)" ]; then
      echo " Failed dependency $LIB/$dependency"
      exit $E_BADDEPS
    fi
  done
else
  echo " Failed dependencies in $SCRIPT"
  exit $E_BADDEPS
fi


REPO=$1
BRANCH=$2
TARGET=$3
TAG=$4
echo "*** Obtaining a working copy of $REPO's $BRANCH branch over $TARGET"

if [ -e $TARGET ]; then
  echo " ABORTED: Target $TARGET already exists"
  exit $E_TARGET_EXISTS
fi

: ${WWW_GR:="www-data"}

REPO_SHORT=$(echo $REPO | $AWK 'BEGIN {FS="/" } ; { print $NF }' | $SED 's/\.git$//')
REPO_TMP="/tmp/repo_for_archive.tmp$$"
ARCH_TMP="/tmp/$REPO_SHORT-$$-tar"

pushd $(pwd)

if [ "${TAG}" != "" ]; then
  cd $REPO
  sudo -u $(stat -c %U .) -g $(stat -c %G .) git tag -f ${TAG} $BRANCH
fi

mkdir -p $REPO_TMP
cd $REPO_TMP
$GIT clone $REPO
cd $REPO_SHORT
$GIT checkout $BRANCH
REPO_HASH=$($GIT rev-parse $BRANCH)
REPO_DATE=$($GIT log $BRANCH -1 --format="%aD")
if [ -e ".gitmodules" ]; then
  $GIT submodule update --init --recursive
  $LIB/git-archive-all.sh $ARCH_TMP
else
  $GIT archive --format=tar $BRANCH -o $ARCH_TMP
fi
cd ~
rm -fr $REPO_TMP

$MKDIR -p $TARGET
$CHOWN :$WWW_GR $TARGET
$CHMOD g+s,o= $TARGET
cd $TARGET
umask 027 && $TAR -xf $ARCH_TMP --no-same-owner --no-same-permissions
echo $REPO_HASH > .git_hash
echo $REPO_DATE > .git_date
rm $ARCH_TMP

cd $(popd)

