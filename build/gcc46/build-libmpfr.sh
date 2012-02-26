#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=mpfr        # App name
VER=3.1.0        # App version
VERHUMAN=$VER    # Human-readable version
PVER=1           # Package Version (numeric only)
PKG=developer/gcc46/libmpfr-gcc46 # Package name (without prefix)
SUMMARY="gcc46 - private libmpfr"
DESC="$SUMMARY" # Longer description
DEPENDS_IPS="developer/gcc46/libgmp-gcc46"

# This stuff is in its own domain
PKGPREFIX=""

[[ "$BUILDARCH" == "both" ]] && BUILDARCH=32
PREFIX=/opt/gcc-4.6.2
CC=gcc
CONFIGURE_OPTS="--with-gmp=/opt/gcc-4.6.2"

make_install32() {
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
