#!/bin/sh

# Type of script: unattended
# To be runned on: -
# To be runned by: root
# Arguments: $SOURCE $TARGET
# Local dependencies: - none -
# Remote dependencies: - none -
# Short description: A script to copy files (and non existant settings.php) from $SOURCE to TARGET Symfony installations

E_BADARGS=65
E_BADDEPS=66
E_SOURCE_DONT_EXISTS=67
E_TARGET_DONT_EXISTS=68

EXPECTED_ARGS=2

#echo $0
if [ $# -ne $EXPECTED_ARGS ]
then
  echo " This script expect $EXPECTED_ARGS arguments instead of $#"
  exit $E_BADARGS
fi

AWK=$(which awk)
MKDIR=$(which mkdir)
RM=$(which rm)
CP=$(which cp)

SOURCE=$1
TARGET=$2
echo "*** Copying files & settings from $SOURCE $TARGET"

if [ ! -d $SOURCE ]; then
  echo " ABORTED: Source $SOURCE doesn't exists"
  exit $E_SOURCE_DONT_EXISTS
fi
if [ ! -d $TARGET ]; then
  echo " ABORTED: Target $TARGET doesn't exists"
  exit $E_TARGET_DONT_EXISTS
fi

S_DIR="$SOURCE/config"
T_DIR="$TARGET/config"

if [ -e ${S_DIR}/databases.yml  ]; then
  echo "Copying config/databases.yml" 
  $CP -a ${S_DIR}/databases.yml ${T_DIR}/databases.yml
fi

if [ -e ${S_DIR}/ProjectConfiguration.class.php  ]; then
  echo "Copying config/ProjectConfiguration.class.php"
  $CP -a ${S_DIR}/ProjectConfiguration.class.php ${T_DIR}/ProjectConfiguration.class.php
fi

if [ -d "${SOURCE}/log" ]; then
  echo "Copying /log"
  cp -a ${SOURCE}/log ${TARGET}/log
else
  echo "Creating /log"
  mkdir -p ${TARGET}/log
fi

if [ -d "${SOURCE}/cache" ]; then
  echo "Copying /cache"
  cp -a ${SOURCE}/cache ${TARGET}/cache
else
  echo "Creating /cache"
  mkdir -p ${TARGET}/cache
fi

if [ -d "${SOURCE}/web/uploads" ]; then
  echo "Copying /uploads"
  cp -a ${SOURCE}/web/uploads ${TARGET}/web/uploads
else
  echo "Creating /uploads"
  mkdir -p ${TARGET}/web/uploads
fi

