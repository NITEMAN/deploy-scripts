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
: ${FRAMEWORK_VERSION:="1"}
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
case ${FRAMEWORK_VERSION} in
  1 )
    CONFIG_S_DIR="${SOURCE}/config"
    CONFIG_T_DIR="${TARGET}/config"
    LOG_S_DIR="${SOURCE}/log"
    LOG_T_DIR="${TARGET}/log"
    CACHE_S_DIR="${SOURCE}/cache"
    CACHE_T_DIR="${TARGET}/cache"
    UPLOADS_S_DIR="${SOURCE}/web/uploads"
    UPLOADS_T_DIR="${TARGET}/web/uploads"
    ;;
  2 )
    CONFIG_S_DIR="${SOURCE}/app/config"
    CONFIG_T_DIR="${TARGET}/app/config"
    LOG_S_DIR="${SOURCE}/app/log"
    LOG_T_DIR="${TARGET}/app/log"
    CACHE_S_DIR="${SOURCE}/app/cache"
    CACHE_T_DIR="${TARGET}/app/cache"
    UPLOADS_S_DIR="${SOURCE}/web/uploads"
    UPLOADS_T_DIR="${TARGET}/web/uploads"
    ;;
  * )
    echo "!!! ERROR: unsupported Framework version '${FRAMEWORK_VERSION}'"
    exit $E_UNSUPPORTED_FW_VERSION
    ;;
esac

if [ -e ${CONFIG_S_DIR}/databases.yml  ]; then
  echo "Copying config/databases.yml" 
  $CP -a ${CONFIG_S_DIR}/databases.yml ${CONFIG_T_DIR}/databases.yml
fi

if [ -e ${CONFIG_S_DIR}/ProjectConfiguration.class.php  ]; then
  echo "Copying config/ProjectConfiguration.class.php"
  $CP -a ${CONFIG_S_DIR}/ProjectConfiguration.class.php ${CONFIG_T_DIR}/ProjectConfiguration.class.php
fi

if [ -e ${CONFIG_S_DIR}/parameters.yml  ]; then
  echo "Copying config/parameters.yml" 
  $CP -a ${CONFIG_S_DIR}/parameters.yml ${CONFIG_T_DIR}/parameters.yml
fi

if [ -d "${LOG_S_DIR}" ]; then
  echo "Copying log"
  cp -a ${LOG_S_DIR} ${LOG_T_DIR}
else
  echo "Creating log"
  mkdir -p ${LOG_T_DIR}
fi

if [ -d "${CACHE_S_DIR}" ]; then
  echo "Copying cache"
  cp -a ${CACHE_S_DIR} ${CACHE_T_DIR}
else
  echo "Creating cache"
  mkdir -p ${CACHE_T_DIR}
fi

if [ -d "${UPLOADS_S_DIR}" ]; then
  echo "Copying uploads"
  cp -a ${UPLOADS_S_DIR} ${UPLOADS_T_DIR}
else
  echo "Creating uploads"
  mkdir -p ${UPLOADS_T_DIR}
fi

