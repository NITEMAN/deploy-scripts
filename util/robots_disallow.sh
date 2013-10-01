#!/bin/bash

E_BADARGS=65

EXPECTED_ARGS=1

if [ $# -ne $EXPECTED_ARGS ]; then
  echo " This script expect $EXPECTED_ARGS arguments instead of $#"
  exit $E_BADARGS
fi

# TODO: Consider using autodeploy-common

ROBOTS_ROOT=$1

cp -a ${ROBOTS_ROOT}/robots.txt ${ROBOTS_ROOT}/robots_orig.txt

echo $(head -n 1 ${ROBOTS_ROOT}/robots_orig.txt) > ${ROBOTS_ROOT}/robots.txt

cat >> ${ROBOTS_ROOT}/robots.txt <<- EOHD
#
# robots.txt
#
# For more information about the robots.txt standard, see:
# http://www.robotstxt.org/wc/robots.html
#
# For syntax checking, see:
# http://www.sxw.org.uk/computing/robots/check.html
#
# you can find original on /robots_orig.txt

User-agent: *
Disallow: /                       
EOHD

exit 0
