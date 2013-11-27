#!/bin/bash

# Type of script: unattended
# To be runned on: -
# To be runned by: root
# Arguments: $SITE $BRANCH $DEP_USER
# Local dependencies: To be runned from an updated repository, git-archive-all.sh
# Remote dependencies: - none -
# Short description: A script to deploy a working copy of $BRANCH from $REPO of $SITE logging $GL_USER
# ${SCRIPT_DIR}/sudo/autodeploy-drupal.sh ${DEPLOY_NAME} ${BRANCH_NAME} ${GL_USER}


E_BADARGS=65

EXPECTED_ARGS=3

if [ $# -ne $EXPECTED_ARGS ]
then
  echo " This script expect $EXPECTED_ARGS arguments instead of $#"
  exit $E_BADARGS
fi

MV=$(which mv)
RM=$(which rm)
DATE=$(which date)
SED=$(which sed)
CAT=$(which cat)


### CONFIG
DEP_NAME=$1
DEP_BRANCH=$2
DEP_USER=$3

. $($(which dirname) $($(which readlink) -f "$0"))/autodeploy-common.sh

# Clonar RAMA REPO con submoduless en dir tmp
# clone-with-subs.sh $REPO $BRANCH $TARGET
. $LIB/clone-with-subs.sh $REPO_BARE $DEP_BRANCH $TMP_DIR

# Copiar files y settings
# copy-files-settings.sh $SOURCE $TARGET
. $LIB/wordpress-copy-files-settings.sh $DST_DIR $TMP_DIR

# Arreglar permisos
# fix-drupal-perms.sh $TARGET
. $LIB/wordpress-fix-perms.sh $TMP_DIR

# Firmar Robots
REPO_HASH=$($CAT $TMP_DIR/.git_hash)
REPO_DATE=$($CAT $TMP_DIR/.git_date)
SIGN="# Environment generated by $DEP_USER from $DEP_BRANCH (hash: $REPO_HASH, date: $REPO_DATE) for site $SITE_NAME on $($DATE '+%Y-%m-%d %H:%M %Z')"
$SED  -i  '1{s|^|'"${SIGN}\n"'|}' $TMP_DIR/robots.txt

# Eliminar archivos no para produccion
$RM $TMP_DIR/.git*

# Loggear despliegue
echo -e "$($DATE '+%Y-%m-%d %H:%M %Z')\t$DEP_BRANCH\t$REPO_DATE\t$REPO_HASH\t$DEP_USER" >> $LOG_FILE

$RM -r $DST_DIR
$MV $TMP_DIR $DST_DIR

# Reload apache
restartServerIfNecesary

# Borrar caches
#TODO: Add support for wp cli

# Clean Varnish
cleanVarnishIfNecesary

exit 0
