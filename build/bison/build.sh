#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=bison      # App name
VER=2.5         # App version
VERHUMAN=$VER   # Human-readable version
PVER=0.1        # Package Version (numeric only)
PKG=developer/parser/bison  # Package name (without prefix)
SUMMARY="Bison is a general-purpose parser generator"
DESC="$SUMMARY" # Longer description

BUILDARCH=32
CONFIGURE_OPTS_32="--prefix=$PREFIX
        --sysconfdir=/etc
        --includedir=$PREFIX/include
        --bindir=$PREFIX/bin
        --sbindir=$PREFIX/sbin
        --libdir=$PREFIX/lib
        --libexecdir=$PREFIX/libexec"
CONFIGURE_OPTS="--disable-yacc"
M4=/usr/bin/gm4
export M4

make_links() {
    logcmd mkdir -p $DESTDIR/usr/sfw/bin
    logcmd ln -s ../../bin/bison $DESTDIR/usr/sfw/bin/bison
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_links
make_isa_stub
fix_permissions
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
