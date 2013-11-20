#!/bin/sh

#set -x

REAL_PATH=$($(which dirname) $($(which readlink) -f "$0"))
LIB="${REAL_PATH}/lib"

REPO_BARE=$(pwd)
REPO_SHORT=$(echo $REPO_BARE | awk 'BEGIN {FS="/" } ; { print $NF }' | sed 's/\.git$//')

ECHO_PREFIX='***'

OWNER=$(git config hooks.deployOwner)
#defaults 
: ${OWNER:="root"}
WWW_US=$(git config hooks.deployWuser)
: ${WWW_US:="www-data"}
WWW_GR=$(git config hooks.deployWgroup)
: ${WWW_GR:="www-data"}
WEB_ROOT=$(git config hooks.deployRoot)
: ${WEB_ROOT:="/var/www"}
SUBDIR=$(git config hooks.deploySubdir)

CONF_OVERWRITE=$(git config hooks.deployConfOverwrite)

SITE_NAME=${DEP_NAME}
LOG_FILE="${REAL_PATH}/log/${SITE_NAME}_autodeploy.log"

DST_DIR="${WEB_ROOT}/${SITE_NAME}/${SUBDIR}"
DST_DIR=${DST_DIR%/}
TMP_DIR="/tmp/deploy_${SITE_NAME}.tmp$$"
