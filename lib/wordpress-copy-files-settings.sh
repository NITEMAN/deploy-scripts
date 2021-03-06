#!/bin/sh

# Type of script: unattended
# To be runned on: -
# To be runned by: root
# Arguments: $SOURCE $TARGET
# Local dependencies: - none -
# Remote dependencies: - none -
# Short description: A script to copy files (and non existant settings.php) from $SOURCE to TARGET Wordpress installations

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

$CP -a $SOURCE/wp-config.php $TARGET/wp-config.php

if [ -e "$SOURCE/wp-content/w3-total-cache-config.php" ]; then
  $CP -a $SOURCE/wp-content/w3-total-cache-config.php $TARGET/wp-content/w3-total-cache-config.php
fi

if [ -d "$SOURCE/wp-content/uploads" ]; then
  $CP -a $SOURCE/wp-content/uploads $TARGET/wp-content/uploads
fi
if [ -d "$SOURCE/wp-content/w3tc" ]; then
  $CP -a $SOURCE/wp-content/w3tc $TARGET/wp-content/w3tc
fi

if [ -e "$SOURCE/sitemap.xml" ]; then
  $CP -a $SOURCE/sitemap.xml $TARGET/sitemap.xml
fi

if [ -e "$SOURCE/sitemap.xml.gz" ]; then
  $CP -a $SOURCE/sitemap.xml.gz $TARGET/sitemap.xml.gz
fi

if [ -d "$SOURCE/wp-content/plugins/bwp-google-xml-sitemaps/cache" ]; then
  $CP -a $SOURCE/wp-content/plugins/bwp-google-xml-sitemaps/cache/*.* $TARGET/wp-content/plugins/bwp-google-xml-sitemaps/cache/
fi

