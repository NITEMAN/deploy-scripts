#!/bin/bash

#set -x

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
GREP=$(which grep)
CAT=$(which cat)
DRUSH=$(which drush)
APA2CTL=$(which apache2ctl)

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
. $LIB/moodle-copy-files-settings.sh $DST_DIR $TMP_DIR

# Arreglar permisos
# fix-drupal-perms.sh $TARGET
. $LIB/moodle-fix-perms.sh $TMP_DIR

# Firmar Robots
REPO_HASH=$($CAT $TMP_DIR/.git_hash)
REPO_DATE=$($CAT $TMP_DIR/.git_date)
SIGN="# Environment generated by $DEP_USER from $DEP_BRANCH (hash: $REPO_HASH, date: $REPO_DATE) for site $SITE_NAME on $($DATE '+%Y-%m-%d %H:%M %Z')"
ROBOTS="$TMP_DIR/robots.txt"
if [ -e $ROBOTS ]; then
  $SED  -i  '1{s|^|'"${SIGN}\n"'|}' $ROBOTS
else
  echo $SIGN > $ROBOTS
fi

# Eliminar archivos no para produccion
$RM $TMP_DIR/.git*

# Loggear despliegue
LOG_DIR=$($(which dirname) "${LOG_FILE}")
if [ ! -d $LOG_DIR ]; then
  mkdir -p $LOG_DIR
fi
echo -e "$($DATE '+%Y-%m-%d %H:%M %Z')\t$DEP_BRANCH\t$REPO_DATE\t$REPO_HASH\t$DEP_USER" >> $LOG_FILE

$RM -r $DST_DIR
$MV $TMP_DIR $DST_DIR

# Reload apache
$APA2CTL restart
# Borrar caches
pushd $(pwd) && cd $DST_DIR && sudo -u $WWW_US /usr/bin/php admin/cli/purge_caches.php && popd
#varnishadm -T :6082 -S /etc/varnish/secret "ban req.http.host ~ '${SITE_NAME}' && req.url ~ '^/'"

exit 0
