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
E_UNSUPPORTED_FW_VERSION=69

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

echo "*** Framework version: ${FRAMEWORK_VERSION} ***"

if [ ! -d $SOURCE ]; then
  echo " ABORTED: Source $SOURCE doesn't exists"
  exit $E_SOURCE_DONT_EXISTS
fi
if [ ! -d $TARGET ]; then
  echo " ABORTED: Target $TARGET doesn't exists"
  exit $E_TARGET_DONT_EXISTS
fi

### Configs
CONFIG_S_DIR="${SOURCE}/htdocs/protected/config"
CONFIG_T_DIR="${TARGET}/htdocs/protected/config"
RUNTIME_S_DIR="${SOURCE}/htdocs/protected/runtime"
RUNTIME_T_DIR="${TARGET}/htdocs/protected/runtime"
ASSETS_S_DIR="${SOURCE}/htdocs/assets"
ASSETS_T_DIR="${TARGET}/htdocs/assets"

if [ -e ${CONFIG_S_DIR}/main.php  ]; then
  echo "Copying config/main.php" 
  $CP -a ${CONFIG_S_DIR}/main.php ${CONFIG_T_DIR}/main.php
fi

if [ -e ${CONFIG_S_DIR}/console.php  ]; then
  echo "Copying config/console.php" 
  $CP -a ${CONFIG_S_DIR}/console.php ${CONFIG_T_DIR}/console.php
fi


if [ -d "${RUNTIME_S_DIR}" ]; then
  echo "Copying protected/runtime"
  cp -a ${RUNTIME_S_DIR} ${RUNTIME_T_DIR}
else
  echo "Creating protected/runtime"
  mkdir -p ${RUNTIME_T_DIR}
fi

if [ -d "${ASSETS_S_DIR}" ]; then
  echo "Copying assets"
  cp -a ${ASSETS_S_DIR} ${ASSETS_T_DIR}
else
  echo "Creating assets"
  mkdir -p ${ASSETS_T_DIR}
fi

