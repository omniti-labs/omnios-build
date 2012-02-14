#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=cabundle   # App name
VER=1.0         # App version
VERHUMAN=$VER   # Human-readable version
PVER=1          # Package Version (numeric only)
PKG=web/ca-bundle  # Package name (without prefix)
SUMMARY="$PROG - Bundle of SSL CA certificates"
DESC="$SUMMARY"

MIRROR=curl.haxx.se

BUILDARCH=32

fetch_pem() {
  logmsg "Fetching PEM file from $MIRROR"
  pushd $TMPDIR > /dev/null
  $WGET -a $LOGFILE http://$MIRROR/ca/cacert.pem ||
    logerr "--- Failed to download PEM file"
  popd > /dev/null
}

install_pem() {
  logmsg "Installing PEM file"
  logcmd mkdir -p $DESTDIR/etc ||
    logerr "--- Unable to create destination directory"
  logmsg "Placing PEM in package root"
  logcmd cp $TMPDIR/cacert.pem $DESTDIR/etc/ ||
    logerr "--- Failed to copy file"
}

init
prep_build
fetch_pem
install_pem
make_package
clean_up
