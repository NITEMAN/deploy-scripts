#!/bin/sh

# Type of script: unattended
# To be runned on: -
# To be runned by: root
# Arguments: $TARGET
# Local dependencies: - none -
# Remote dependencies: - none -
# Short description: A script to fix file permissions on a TARGET Symfony installations

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
F_DIR_1="$DIR/web/uploads"
F_DIR_2="$DIR/cache"
F_DIR_3="$DIR/log"
A_SET="$DIR/config/databases.yml"
A_SET_2="$DIR/config/ProjectConfiguration.class.php"

FIND_NO_F_DIRS="$FIND $DIR -wholename '$F_DIR_1' -prune -or -wholename '$F_DIR_2' -prune -or -wholename '$F_DIR_3' -prune"

echo "*** Fixing permissions ***"
# Generales
#echo "find $DIR \( ! -user root -or ! -group $WWW_GR \)"
#$FIND $DIR -wholename "$F_DIR" -prune -or  \( ! -user root -or ! -group $WWW_GR \) -print
$FIND_NO_F_DIRS -or  \( ! -user root -or ! -group $WWW_GR \) -exec $CHOWN root:$WWW_GR {} \;
#echo "find $DIR \( -type d -and ! -perm u=rwx,g=rxs,o= \)"
#$FIND $DIR -wholename "$F_DIR" -prune -or \( -type d -and ! -perm u=rwx,g=rxs,o= \)
$FIND_NO_F_DIRS -or \( -type d -and ! -perm u=rwx,g=rxs,o= \) -exec $CHMOD u=rwx,g=rxs,o= {} \;
#echo "find $DIR \( -type f -and ! -perm u=rw,g=r,o= \)"
#$FIND $DIR -wholename "$F_DIR" -prune -or \( -type f -and ! -perm u=rw,g=r,o= \)
$FIND_NO_F_DIRS -or \( -type f -and ! -perm u=rw,g=r,o= \) -exec $CHMOD u=rw,g=r,o= {} \;

# Permisos Files
if [ -d $F_DIR_1 ]; then
  $CHMOD 2770 $F_DIR_1
  $FIND $F_DIR_1 \( ! -user $WWW_US -or ! -group $WWW_GR \) -exec $CHOWN $WWW_US:$WWW_GR {} \;
  $FIND $F_DIR_1 \( -type d -and ! -perm u=rwx,g=rwxs,o= \) -exec $CHMOD u=rwx,g=rwxs,o= {} \;
  $FIND $F_DIR_1 \( -type f -and ! -perm u=rw,g=rw,o= \) -exec $CHMOD u=rw,g=rw,o= {} \;
fi
if [ -d $F_DIR_2 ]; then
  $CHMOD 2755 $F_DIR_2
  $FIND $F_DIR_2 \( ! -user $WWW_US -or ! -group $WWW_GR \) -exec $CHOWN $WWW_US:$WWW_GR {} \;
  #looking for a quicker command
  #$FIND $F_DIR_2 \( -type d -and ! -perm u=rwx,g=rx,o=rx \) -exec $CHMOD u=rwx,g=rx,o=rx {} \;
  $FIND $F_DIR_2 \( -type d -and ! \( -perm u=rwx,g=rx,o=rx -or -perm u=rwx,g=rxs,o=rx \) \) -exec $CHMOD u=rwx,g=rx,o=rx {} \;
  $FIND $F_DIR_2 \( -type f -and ! -perm u=rw,g=r,o=r \) -exec $CHMOD u=rw,g=r,o=r {} \;
fi
if [ -d $F_DIR_3 ]; then
  $CHMOD 2755 $F_DIR_3
  $FIND $F_DIR_3 \( ! -user $WWW_US -or ! -group $WWW_GR \) -exec $CHOWN $WWW_US:$WWW_GR {} \;
  #looking for a quicker command
  #$FIND $F_DIR_3 \( -type d -and ! -perm u=rwx,g=rx,o=rx \) -exec $CHMOD u=rwx,g=rx,o=rx {} \;
  $FIND $F_DIR_3 \( -type d -and ! \( -perm u=rwx,g=rx,o=rx -or -perm u=rwx,g=rxs,o=rx \) \) -exec $CHMOD u=rwx,g=rx,o=rx {} \;
  $FIND $F_DIR_3 \( -type f -and ! -perm u=rw,g=r,o=r \) -exec $CHMOD u=rw,g=r,o=r {} \;
fi

#Permisos Setings 440
$CHMOD 440 $A_SET
$CHMOD 440 $A_SET_2

exit 0

