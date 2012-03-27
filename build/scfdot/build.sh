#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=scfdot
VER=1.0
VERHUMAN=$VER
PVER=1
PKG=system/utility/scfdot
SUMMARY="scfdot - SMF Dependency Graph Generator"
DESC="scfdot - Generate a graphviz file of SMF services and dependencies"

DEPENDS_IPS="system/library"

BUILDARCH=32

configure32() {
    true
}

make_prog() {
    logmsg "--- make"
    logcmd $MAKE CC=$CC scfdot || \
        logerr "--- Make failed"
}

make_install() {
    logmsg "--- make install"
    logcmd mkdir -p $DESTDIR$PREFIX/bin
    logcmd cp scfdot $DESTDIR$PREFIX/bin
    logcmd chmod 0555 $DESTDIR$PREFIX/bin/scfdot
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
