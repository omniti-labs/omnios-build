#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PATH=/opt/gcc-4.6.2/bin:$PATH
export LD_LIBRARY_PATH=/opt/gcc-4.6.2/lib

PROG=gmp         # App name
VER=5.0.2        # App version
VERHUMAN=$VER    # Human-readable version
PVER=1           # Package Version (numeric only)
PKG=developer/gcc46/libgmp-gcc46 # Package name (without prefix)
SUMMARY="gcc46 - private libgmp"
DESC="$SUMMARY" # Longer description

# This stuff is in its own domain
PKGPREFIX=""

[[ "$BUILDARCH" == "both" ]] && BUILDARCH=32
PREFIX=/opt/gcc-4.6.2
CC=gcc
CONFIGURE_OPTS="--enable-cxx"
CFLAGS="-fexceptions"

make_install32() {
    logcmd mkdir -p $DESTDIR/opt/gcc-4.6.2/share/info
    make_install
    logcmd rm -rf $DESTDIR/opt/gcc-4.6.2/share/info
}

reset_configure_opts
init
download_source $PROG $PROG $VER
prep_build
build
make_isa_stub
fix_permissions
make_package
clean_up
