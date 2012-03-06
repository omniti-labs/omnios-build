#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=rsync
VER=3.0.9
VERHUMAN=$VER
PVER=0.1
PKG=network/rsync
SUMMARY="rsync - faster, flexible replacement for rcp"
DESC="rsync - faster, flexible replacement for rcp"

BUILDARCH=32
CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32 --bindir=/usr/bin --with-included-popt"
init
download_source $PROG $PROG $VER
patch_source
prep_build
build
cp $TMPDIR/$BUILDDIR/COPYING $DESTDIR/LICENSE
make_isa_stub
fix_permissions
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
