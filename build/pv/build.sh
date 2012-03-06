#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=pv
VER=1.2.0
VERHUMAN=$VER
PVER=0.151002
PKG=shell/pipe-viewer
SUMMARY="Pipe Viewer"
DESC="pipeline monitoring tool (1.2.0)"

BUILDARCH=32
DO_GZIP=true
export DO_GZIP
CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32 --bindir=/usr/bin --mandir=/usr/share/man --disable-nls"
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
