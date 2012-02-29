#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=libffi     # App name
VER=3.0.10      # App version
VERHUMAN=$VER   # Human-readable version
PVER=0.1        # Package Version (numeric only)
PKG=library/libffi
SUMMARY="A Portable Foreign Function Interface Library"
DESC="$SUMMARY"

CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32 --includedir=/usr/lib/libffi-3.0.10/include"
CONFIGURE_OPTS_64="$CONFIGURE_OPTS_64 --includedir=/usr/lib/amd64/libffi-3.0.10/include"

make_prog32() {
    logmsg "Making program (32)"
    logcmd gmake
    pushd i386-pc-solaris2.11 > /dev/null
    logcmd gmake clean
    logcmd gmake || logerr "make failed"
    popd > /dev/null
}
make_install32() {
    logmsg "Installing program (32)"
    pushd i386-pc-solaris2.11 > /dev/null
    logcmd gmake install DESTDIR="$DESTDIR"
    popd > /dev/null
}

make_prog64() {
    logmsg "Making program (64)"
    logcmd gmake
    pushd i386-pc-solaris2.11 > /dev/null
    logcmd gmake clean
    logcmd gmake || logerr "make failed"
    popd > /dev/null
}
make_install64() {
    logmsg "Installing program (64)"
    pushd i386-pc-solaris2.11 > /dev/null
    logcmd gmake install DESTDIR="$DESTDIR"
    popd > /dev/null
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_permissions
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
