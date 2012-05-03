#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

## This is mod_log_rotate for Apache 2.x ##

PROG=mod_log_rotate
VER=2
PKG=omniti/server/apache22/mod_log_rotate
SUMMARY="$PROG - Apache Log Rotation Module"
DESC="$SUMMARY"

DEPENDS_IPS="omniti/server/apache22"
unset PREFIX

build32() {
  local APXS=/opt/apache22/bin/$ISAPART/apxs
  logmsg "Building 32-bit"
  export ISALIST="$ISAPART"
  logcmd $APXS -c ${PROG}.c || \
    logerr "--- build failed"
  logcmd mkdir -p $DESTDIR`$APXS -q LIBEXECDIR`
  logcmd cp .libs/${PROG}.so $DESTDIR`$APXS -q LIBEXECDIR`/${PROG}.so || \
    logerr "--- install failed"
  logmsg "Cleaning up"
  logcmd rm -f ${PROG}.[osl]*
  logcmd rm -rf .libs
  unset ISALIST
  export ISALIST
}

build64() {
  local APXS=/opt/apache22/bin/$ISAPART64/apxs
  logmsg "Building 64-bit"
  logcmd $APXS -c ${PROG}.c || \
    logerr "--- build failed"
  logcmd mkdir -p $DESTDIR`$APXS -q LIBEXECDIR`
  logcmd cp .libs/${PROG}.so $DESTDIR`$APXS -q LIBEXECDIR`/${PROG}.so || \
    logerr "--- install failed"
  logmsg "Cleaning up"
  logcmd rm -f ${PROG}.[osl]*
  logcmd rm -rf .libs
}

init
prep_build
build
make_package
clean_up
