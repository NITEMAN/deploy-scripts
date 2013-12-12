#!/bin/sh

# Type of script: unattended
# To be runned on: -
# To be runned by: root
# Arguments: $TARGET
# Local dependencies: - none -
# Remote dependencies: - none -
# Short description: A script to fix file permissions on a TARGET Prestashop installations

E_BADARGS=65
E_BADDEPS=66
E_TARGET_DONT_EXISTS=68

EXPECTED_ARGS=1

#echo $0
if [ $# -ne $EXPECTED_ARGS ]
then
  echo " This script expect $EXPECTED_ARGS arguments instead of $#"
  exit $E_BADARGS
fi

FIND=$(which find)
CHMOD=$(which chmod)
CHOWN=$(which chown)
SED=$(which sed)

#TARGET=$1
TARGET=$(echo $1 | $SED -e "s/\/*$//")
echo "*** Fixing file permissions for $TARGET"

if [ ! -d $TARGET ]; then
  echo " ABORTED: Target $TARGET doesn't exists"
  exit $E_TARGET_DONT_EXISTS
fi

: ${OWNER:="root"}
: ${WWW_US:="www-data"}
: ${WWW_GR:="www-data"}

DIR=$TARGET
WWW_WRITE_PERMS=(config tools/smarty/cache tools/smarty/compile tools/smarty/cache tools/smarty_v2/cache tools/smarty_v2/compile sitemap.xml log)
WWW_WRITE_PERMS_RECURSIVELY=(img mails modules themes/prestashop/lang themes/prestashop/cache translations upload download)
A_SET="$DIR/config/settings.inc.php"

echo "*** Fixing permissions ***"
# General
WWW_WRITE_ALL=("${WWW_WRITE_PERMS[@]}" "${WWW_WRITE_PERMS_RECURSIVELY[@]}")
FIND_NO_F_DIRS="$FIND -H $DIR"
for F_DIR in "${WWW_WRITE_ALL[@]}"
do
  FIND_NO_F_DIRS="$FIND_NO_F_DIRS -wholename \"$F_DIR\" -prune -or"
done
FIND_NO_F_DIRS=${FIND_NO_F_DIRS:0:-4}

eval "$FIND_NO_F_DIRS -or  \( ! -user root -or ! -group $WWW_GR \) -exec $CHOWN root:$WWW_GR {} \;"
eval "$FIND_NO_F_DIRS -or \( -type d -and ! -perm u=rwx,g=rxs,o= \) -exec $CHMOD u=rwx,g=rxs,o= {} \;"
eval "$FIND_NO_F_DIRS -or \( -type f -and ! -perm u=rw,g=r,o= \) -exec $CHMOD u=rw,g=r,o= {} \;"

# Write permissions
for F_DIR in "${WWW_WRITE_PERMS[@]}"
do
  $CHOWN $WWW_US:$WWW_GR $DIR/$F_DIR
  if [ -d $DIR/$F_DIR ]
  then
    $CHMOD 2755 $DIR/$F_DIR
  else
    $CHMOD 644 $DIR/$F_DIR
  fi
done

# Write permissions recursively
for F_DIR in "${WWW_WRITE_PERMS_RECURSIVELY[@]}"
do
  $CHOWN -R $WWW_US:$WWW_GR $DIR/$F_DIR
  $CHMOD 2755 $DIR/$F_DIR
  $FIND $DIR/$F_DIR \( ! -user $WWW_US -or ! -group $WWW_GR \) -exec $CHOWN $WWW_US:$WWW_GR {} \;
  $FIND $DIR/$F_DIR \( -type d -and ! \( -perm u=rwx,g=rx,o=rx -or -perm u=rwx,g=rxs,o=rx \) \) -exec $CHMOD u=rwx,g=rx,o=rx {} \;
  $FIND $DIR/$F_DIR \( -type f -and ! -perm u=rw,g=r,o=r \) -exec $CHMOD u=rw,g=r,o=r {} \;
done

# setings.inc.php
$CHMOD 440 $A_SET
