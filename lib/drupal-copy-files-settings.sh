#!/bin/sh

# Type of script: unattended
# To be runned on: -
# To be runned by: root
# Arguments: $SOURCE $TARGET
# Local dependencies: - none -
# Remote dependencies: - none -
# Short description: A script to copy files (and non existant settings.php) from $SOURCE to TARGET Drupal installations

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

S_DIR="$SOURCE/sites"
T_DIR="$TARGET/sites"

# For each directory except "all" inside $SOURCE's sites 
for drup_site in $S_DIR/*; do
  if [ -d $drup_site ]; then
    if [ ! $drup_site = "$S_DIR/all" ]; then
      d_site=$(echo $drup_site | $AWK 'BEGIN {FS="/" } ; { print $NF }')
      # If the site doesn't exits we recreate it
      if [ ! -d "$T_DIR/$d_site" ]; then
        $MKDIR -p $T_DIR/$d_site
      fi
      # If there are files directory on source we replace target's with a copy of it
      if [ -d "$drup_site/files" ]; then 
        $RM -fr $T_DIR/$d_site/files
        $CP -a $drup_site/files $T_DIR/$d_site
      fi
      # If there are private directory on source we replace target's with a copy of it
      if [ -d "$drup_site/private" ]; then 
        $RM -fr $T_DIR/$d_site/private
        $CP -a $drup_site/private $T_DIR/$d_site
      fi
      # We only copy settings.php if it doesn't exists on target or if a flag is set
      if [ ! "${CONF_OVERWRITE}" = 'true' ] || [ ! -e "$T_DIR/$d_site/settings.php" ] ; then
        $CP -a $drup_site/settings.php $T_DIR/$d_site/ 
      else
        if [ ! "${CONF_OVERWRITE}" = 'no_warn' ]; then
          echo "WARNING: $T_DIR/$d_site/settings.php already exists NOT overwritten"
        fi
      fi
    fi
  fi
done

# For each directory except "all" inside $TARGET's sites
for drup_site in $T_DIR/*; do
  if [ -d $drup_site ]; then
    if [ ! $drup_site = "$T_DIR/all" ]; then
      # Ensure that files directory exists 
      if [ ! -d "$drup_site/files" ]; then 
        $MKDIR $drup_site/files 
      fi
      # Ensure that private directory exists 
      if [ ! -d "$drup_site/private" ]; then 
        $MKDIR $drup_site/private 
      fi
    fi
  fi
done

