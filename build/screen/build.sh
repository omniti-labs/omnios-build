#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=screen     # App name
VER=4.0.3       # App version
PVER=0.151002          # Package Version
PKG=terminal/screen      # Package name (without prefix)
SUMMARY="GNU Screen terminal multiplexer"
DESC="$SUMMARY"

gnu_cleanup() {
    logcmd rm -f $DESTDIR/usr/bin/{i386,amd64}/screen
    logcmd mv $DESTDIR/usr/bin/i386/screen-4.0.3 $DESTDIR/usr/bin/i386/screen
    logcmd mv $DESTDIR/usr/bin/amd64/screen-4.0.3 $DESTDIR/usr/bin/amd64/screen
    logcmd mv $DESTDIR/usr/man $DESTDIR/usr/share/
    logcmd mv $DESTDIR/usr/info $DESTDIR/usr/share/
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
gnu_cleanup
make_isa_stub
fix_permissions
make_package
clean_up
