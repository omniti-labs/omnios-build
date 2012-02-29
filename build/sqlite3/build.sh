#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=sqlite-autoconf      # App name
VER=3071000         # App version
VERHUMAN=3.7.10  # Human-readable version
PVER=0.1          # Package Version (numeric only)
PKG=database/sqlite-3       # Package name (without prefix)
SUMMARY="SQL database engine library"      # You should change this
DESC="$SUMMARY"

DEPENDS_IPS="SUNWcs library/readline system/library/gcc-4-runtime"
CONFIGURE_OPTS_64="$CONFIGURE_OPTS_64 --includedir=/usr/include"

make_stub_dirs() {
    logcmd mkdir -p $DESTDIR/usr/bin
    logcmd mkdir -p $DESTDIR/usr/lib
    logcmd mkdir -p $DESTDIR/usr/include
    logcmd mkdir -p $DESTDIR/usr/lib/amd64
    logcmd mkdir -p $DESTDIR/usr/share/man/man1
}

init
download_source sqlite $PROG $VER
patch_source
prep_build
make_stub_dirs
build
make_isa_stub
fix_permissions
VER=3.7.10
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
