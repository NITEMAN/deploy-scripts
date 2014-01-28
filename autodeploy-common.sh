#!/bin/sh

#set -x

REAL_PATH=$($(which dirname) $($(which readlink) -f "$0"))
LIB="${REAL_PATH}/lib"

REPO_BARE=$(pwd)
REPO_SHORT=$(echo $REPO_BARE | awk 'BEGIN {FS="/" } ; { print $NF }' | sed 's/\.git$//')

ECHO_PREFIX='***'

OWNER=$(git config hooks.deployOwner)
WWW_US=$(git config hooks.deployWuser)
WWW_GR=$(git config hooks.deployWgroup)
WEB_ROOT=$(git config hooks.deployRoot)
SUBDIR=$(git config hooks.deploySubdir)
CONF_OVERWRITE=$(git config hooks.deployConfOverwrite)
FRAMEWORK_VERSION=$(git config hooks.deployFrameworkVersion)
RELOAD_SERVER=$(git config hooks.deployReloadServer)
RELOAD_CMD=$(git config hooks.deployReloadCMD)
CLEAN_VARNISH=$(git config hooks.deployCleanVarnish)
VARNISH_ADM_OPTS=$(git config hooks.deployVarnishiAdmOpts)

#defaults
: ${OWNER:="root"}
: ${WWW_US:="www-data"}
: ${WWW_GR:="www-data"}
: ${WEB_ROOT:="/var/www"}

: ${RELOAD_SERVER:='false'}
: ${RELOAD_CMD:='/usr/sbin/apache2ctl graceful'}

: ${CLEAN_VARNISH:='false'}

: ${VARNISH_ADM_OPTS:='-T :6082 -S /etc/varnish/secret'}

SITE_NAME=${DEP_NAME}
LOG_FILE="${REAL_PATH}/log/${SITE_NAME}_autodeploy.log"

DST_DIR="${WEB_ROOT}/${SITE_NAME}/${SUBDIR}"
DST_DIR=${DST_DIR%/}
TMP_DIR="/tmp/deploy_${SITE_NAME}.tmp$$"

restartServerIfNecesary() {
  if [ "${RELOAD_SERVER}" = 'true' ]; then
    echo "${ECHO_PREFIX} Restarting server with command: ${RELOAD_CMD}"
    eval ${RELOAD_CMD}
  fi
  return 0
}

cleanVarnishIfNecesary() {
  if [ "${CLEAN_VARNISH}" = 'true' ]; then
    VARNISH_CMD="varnishadm ${VARNISH_ADM_OPTS} \"ban req.http.host ~ \"${SITE_NAME}\" && req.url ~ \"^/\"\""
    echo "${ECHO_PREFIX} Cleaning Varnish server with command: ${VARNISH_CMD}"
    eval ${VARNISH_CMD}
  fi
  return 0
}

