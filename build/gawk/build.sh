#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=gawk
VER=4.0.0
VERHUMAN=$VER
PVER=0.1
PKG=text/gawk
SUMMARY="gawk - GNU implementation of awk"
DESC="$SUMMARY"

BUILDARCH=32
CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32 --bindir=/usr/bin"

gnu_cleanup() {
    logmsg "Cleaning up install root"
    logcmd mkdir -p $DESTDIR/usr/gnu/bin
    logcmd mkdir -p $DESTDIR/usr/gnu/share/man/man1
    logcmd ln -s ../../bin/gawk $DESTDIR/usr/gnu/bin/awk
    logcmd ln -s ../../../../share/man/man1/gawk.1 $DESTDIR/usr/gnu/share/man/man1/awk.1
    logcmd rm $DESTDIR/usr/bin/{awk,gawk-4.0.0,pgawk-4.0.0}
    logcmd rm -rf $DESTDIR/usr/libexec
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

# Vim hints
# vim:ts=4:sw=4:et:
