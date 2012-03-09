#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=ncurses    # App name
VER=5.9         # App version
VERHUMAN=$VER   # Human-readable version
PVER=1          # Package Version (numeric only)
PKG=library/ncurses  # Package name (without prefix)
SUMMARY="A CRT screen handling and optimization package."
DESC="$SUMMARY"

DEPENDS_IPS="shell/bash system/library"

CONFIGURE_OPTS="
    --with-normal
    --with-shared
    --enable-rpath
    --enable-widec
    --without-debug
"

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
